# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "cgi"
require_relative "item_types"
require_relative "fields"
require_relative "file_upload"
require_relative "http_errors"
require_relative "syncing"
require_relative "http_config"
require_relative "http_connection"
require_relative "network_errors"

module Zotero
  # The main HTTP client for interacting with the Zotero Web API v3.
  # Provides authentication, request handling, and access to library operations.
  #
  # @example Create a client with API key
  #   client = Zotero::Client.new(api_key: 'your-api-key-here')
  #   library = client.user_library(12345)
  #
  # rubocop:disable Metrics/ClassLength
  class Client
    include ItemTypes
    include Fields
    include FileUpload
    include HTTPErrors
    include Syncing
    include NetworkErrors

    BASE_URI = "https://api.zotero.org"

    # Initialize a new Zotero API client.
    #
    # @param api_key [String] Your Zotero API key from https://www.zotero.org/settings/keys
    # @raise [ArgumentError] if api_key is nil or empty
    def initialize(api_key:)
      @api_key = api_key
    end

    # Get a Library instance for a specific user.
    #
    # @param user_id [Integer, String] The Zotero user ID
    # @return [Library] A Library instance for the specified user
    def user_library(user_id)
      Library.new(client: self, type: :user, id: user_id)
    end

    # Get a Library instance for a specific group.
    #
    # @param group_id [Integer, String] The Zotero group ID
    # @return [Library] A Library instance for the specified group
    def group_library(group_id)
      Library.new(client: self, type: :group, id: group_id)
    end

    # Make a GET request to the Zotero API.
    # This is the main public interface for read operations.
    #
    # @param path [String] The API endpoint path
    # @param params [Hash] Query parameters for the request
    # @return [Array, Hash] The parsed response data
    def make_get_request(path, params: {})
      headers = auth_headers.merge(default_headers)
      response = http_request(:get, path, headers: headers, params: params)
      handle_response(response, params[:format])
    end

    # Make a write request (POST, PATCH, PUT, DELETE) to the Zotero API.
    # This is the main public interface for write operations.
    #
    # @param method [Symbol] The HTTP method (:post, :patch, :put, :delete)
    # @param path [String] The API endpoint path
    # @param data [Hash, Array] Optional request body data
    # @param options [Hash] Write options (version: Integer, write_token: String)
    # @param params [Hash] Query parameters for the request
    # @return [Hash, Boolean] The parsed response data or success status
    def make_write_request(method, path, data: nil, options: {}, params: {})
      headers = build_write_headers(version: options[:version], write_token: options[:write_token])
      response = http_request(method, path, headers: headers, body: data, params: params)
      handle_write_response(response)
    end

    protected

    def http_request(method, path, **options)
      request_options = build_request_options(options)
      uri = build_uri(path, request_options[:params])

      handle_network_errors do
        connection = HTTPConnection.new(uri)
        request = build_request(method, uri, request_options[:headers], request_options[:body], request_options)

        connection.request(request)
      end
    end

    def auth_headers
      { "Zotero-API-Key" => api_key }
    end

    def default_headers
      { "Zotero-API-Version" => "3" }
    end

    def build_write_headers(version: nil, write_token: nil)
      headers = auth_headers.merge(default_headers)
      headers["Content-Type"] = "application/json"
      headers["If-Unmodified-Since-Version"] = version.to_s if version
      headers["Zotero-Write-Token"] = write_token if write_token
      headers
    end

    def handle_response(response, format = nil)
      return parse_response_body(response, format) if response.code.to_i.between?(200, 299)

      raise_error_for_status(response)
    end

    def handle_write_response(response)
      case response.code.to_i
      when 200
        parse_json_response(response)
      when 204
        true
      else
        raise_error_for_status(response)
      end
    end

    private

    attr_reader :api_key

    def build_request_options(options)
      {
        headers: options[:headers] || {},
        body: options[:body],
        params: options[:params] || {},
        multipart: options[:multipart],
        format: options[:format]
      }
    end

    def build_uri(path, params = {})
      base = path.start_with?("http") ? path : "#{BASE_URI}#{path}"
      uri = URI(base)

      unless params.empty?
        query_params = params.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
        uri.query = uri.query ? "#{uri.query}&#{query_params}" : query_params
      end

      uri
    end

    def build_request(method, uri, headers, body, request_options)
      request = create_request(method, uri)
      set_headers(request, headers)
      set_request_body(request, method, body, headers, request_options) if body
      request
    end

    def create_request(method, uri)
      request_class = case method
                      when :get then Net::HTTP::Get
                      when :post then Net::HTTP::Post
                      when :put then Net::HTTP::Put
                      when :patch then Net::HTTP::Patch
                      when :delete then Net::HTTP::Delete
                      else raise ArgumentError, "Unsupported HTTP method: #{method}"
                      end

      request_class.new(uri)
    end

    def set_headers(request, headers)
      headers.each { |key, value| request[key] = value }
    end

    def set_request_body(request, method, body, headers, request_options)
      return unless %i[post put patch].include?(method)

      if request_options[:multipart]
        request.set_form(body, "multipart/form-data")
      elsif headers["Content-Type"] == "application/x-www-form-urlencoded"
        request.set_form_data(body)
      else
        request.body = body.is_a?(String) ? body : JSON.generate(body)
        request["Content-Type"] = "application/json" unless headers["Content-Type"]
      end
    end

    def parse_response_body(response, format)
      case format&.to_s
      when "json", nil
        parse_json_response(response)
      else
        response.body
      end
    end

    def parse_json_response(response)
      return nil if response.body.nil? || response.body.empty?

      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end
  end
  # rubocop:enable Metrics/ClassLength
end
