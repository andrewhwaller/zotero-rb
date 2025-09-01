# frozen_string_literal: true

require "httparty"

module Zotero
  class Client
    include HTTParty

    base_uri "https://api.zotero.org"
    format :json

    def initialize(api_key:)
      @api_key = api_key
    end

    def get(path)
      response = self.class.get(path, headers: auth_headers.merge(default_headers))
      handle_response(response)
    end

    private

    attr_reader :api_key

    def auth_headers
      { "Zotero-API-Key" => api_key }
    end

    def default_headers
      { "Zotero-API-Version" => "3" }
    end

    def handle_response(response)
      case response.code
      when 200..299
        response.parsed_response
      when 401
        raise Error, "Authentication failed - check your API key"
      when 404
        raise Error, "Resource not found: #{response.request.path}"
      else
        raise Error, "HTTP #{response.code}: #{response.message}"
      end
    end
  end
end
