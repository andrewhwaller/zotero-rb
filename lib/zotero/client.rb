# frozen_string_literal: true

require "httparty"
require_relative "item_types"
require_relative "fields"
require_relative "file_upload"
require_relative "http_errors"
require_relative "syncing"

module Zotero
  class Client
    include HTTParty
    include ItemTypes
    include Fields
    include FileUpload
    include HTTPErrors
    include Syncing

    base_uri "https://api.zotero.org"
    format :json

    def initialize(api_key:)
      @api_key = api_key
    end

    def get(path, params: {})
      response = self.class.get(path,
                                headers: auth_headers.merge(default_headers),
                                query: params)
      handle_response(response, params[:format])
    end

    def post(path, data:, version: nil, write_token: nil, params: {})
      headers = build_write_headers(version: version, write_token: write_token)
      response = self.class.post(path,
                                 headers: headers,
                                 body: data,
                                 query: params)
      handle_write_response(response)
    end

    def patch(path, data:, version: nil, params: {})
      headers = build_write_headers(version: version)
      response = self.class.patch(path,
                                  headers: headers,
                                  body: data,
                                  query: params)
      handle_write_response(response)
    end

    def put(path, data:, version: nil, params: {})
      headers = build_write_headers(version: version)
      response = self.class.put(path,
                                headers: headers,
                                body: data,
                                query: params)
      handle_write_response(response)
    end

    def delete(path, version: nil, params: {})
      headers = build_write_headers(version: version)
      response = self.class.delete(path,
                                   headers: headers,
                                   query: params)
      handle_write_response(response)
    end

    def user_library(user_id)
      Library.new(client: self, type: :user, id: user_id)
    end

    def group_library(group_id)
      Library.new(client: self, type: :group, id: group_id)
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
end
