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

module Zotero
  # The main HTTP client for interacting with the Zotero Web API v3.
  # Provides authentication, request handling, and access to library operations.
  #
  # @example Create a client with API key
  #   client = Zotero::Client.new(api_key: 'your-api-key-here')
  #   library = client.user_library(12345)
  #
  class Client
    include ItemTypes
    include Fields
    include FileUpload
    include HTTPErrors
    include Syncing

    BASE_URI = "https://api.zotero.org"

    # Initialize a new Zotero API client.
    #
    # @param api_key [String] Your Zotero API key from https://www.zotero.org/settings/keys
    def initialize(api_key:)
      @api_key = api_key
    end

    def get(path, params: {})
      response = http_request(:get, path, 
                             headers: auth_headers.merge(default_headers),
                             params: params)
      handle_response(response, params[:format])
    end

    def post(path, data:, version: nil, write_token: nil, params: {})
      headers = build_write_headers(version: version, write_token: write_token)
      response = http_request(:post, path,
                             headers: headers,
                             body: data,
                             params: params)
      handle_write_response(response)
    end

    def patch(path, data:, version: nil, params: {})
      headers = build_write_headers(version: version)
      response = http_request(:patch, path,
                             headers: headers,
                             body: data,
                             params: params)
      handle_write_response(response)
    end

    def put(path, data:, version: nil, params: {})
      headers = build_write_headers(version: version)
      response = http_request(:put, path,
                             headers: headers,
                             body: data,
                             params: params)
      handle_write_response(response)
    end

    def delete(path, version: nil, params: {})
      headers = build_write_headers(version: version)
      response = http_request(:delete, path,
                             headers: headers,
                             params: params)
      handle_write_response(response)
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

    protected

    def http_request(method, path, headers: {}, body: nil, params: {}, multipart: false, format: nil)
      uri = build_uri(path, params)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      
      request = build_request(method, uri, headers, body, multipart, format)
      
      net_response = http.request(request)
      ResponseAdapter.new(net_response, uri)
    end

    def build_uri(path, params = {})
      base = path.start_with?('http') ? path : "#{BASE_URI}#{path}"
      uri = URI(base)
      
      unless params.empty?
        query_params = params.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
        uri.query = uri.query ? "#{uri.query}&#{query_params}" : query_params
      end
      
      uri
    end

    def build_request(method, uri, headers, body, multipart, format)
      request_class = case method
                     when :get then Net::HTTP::Get
                     when :post then Net::HTTP::Post
                     when :put then Net::HTTP::Put
                     when :patch then Net::HTTP::Patch
                     when :delete then Net::HTTP::Delete
                     else raise ArgumentError, "Unsupported HTTP method: #{method}"
                     end

      request = request_class.new(uri)
      
      headers.each { |key, value| request[key] = value }
      
      if body && [:post, :put, :patch].include?(method)
        if multipart
          # Handle multipart form data for file uploads
          request.set_form(body, 'multipart/form-data')
        elsif headers['Content-Type'] == 'application/x-www-form-urlencoded'
          # Handle form encoding
          request.set_form_data(body)
        else
          # Handle JSON body
          request.body = body.is_a?(String) ? body : JSON.generate(body)
          request['Content-Type'] = 'application/json' unless headers['Content-Type']
        end
      end
      
      request
    end

    private

    attr_reader :api_key

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
      return parse_response_body(response, format) if response.code.between?(200, 299)

      raise_error_for_status(response)
    end

    def handle_write_response(response)
      case response.code
      when 200
        response.parsed_response
      when 204
        true
      else
        raise_error_for_status(response)
      end
    end

    def parse_response_body(response, format)
      case format&.to_s
      when "json", nil
        response.parsed_response
      else
        response.body
      end
    end
  end

  # Adapter to provide HTTParty-compatible interface for Net::HTTP responses
  class ResponseAdapter
    attr_reader :net_response, :uri

    def initialize(net_response, uri)
      @net_response = net_response
      @uri = uri
    end

    def code
      @net_response.code.to_i
    end

    def parsed_response
      @parsed_response ||= parse_body
    end

    def body
      @net_response.body
    end

    def headers
      @headers ||= @net_response.to_hash.transform_values(&:first)
    end

    def message
      @net_response.message
    end

    def request
      @request ||= RequestAdapter.new(@uri)
    end

    private

    def parse_body
      content_type = @net_response.content_type
      return nil if @net_response.body.nil? || @net_response.body.empty?

      if content_type&.include?('application/json')
        JSON.parse(@net_response.body)
      else
        @net_response.body
      end
    rescue JSON::ParserError
      @net_response.body
    end
  end

  # Adapter to provide request.path access for error handling
  class RequestAdapter
    attr_reader :path

    def initialize(uri)
      @path = uri.path
    end
  end
end
