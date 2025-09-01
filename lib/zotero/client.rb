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

    def get(path, params: {})
      response = self.class.get(path,
                                headers: auth_headers.merge(default_headers),
                                query: params)
      handle_response(response, params[:format])
    end

    def user_library(user_id)
      Library.new(client: self, type: :user, id: user_id)
    end

    def group_library(group_id)
      Library.new(client: self, type: :group, id: group_id)
    end

    def item_types(locale: nil)
      params = {}
      params[:locale] = locale if locale
      get("/itemTypes", params: params)
    end

    def item_fields(locale: nil)
      params = {}
      params[:locale] = locale if locale
      get("/itemFields", params: params)
    end

    def item_type_fields(item_type, locale: nil)
      params = { itemType: item_type }
      params[:locale] = locale if locale
      get("/itemTypeFields", params: params)
    end

    def creator_fields(locale: nil)
      params = {}
      params[:locale] = locale if locale
      get("/creatorFields", params: params)
    end

    def item_type_creator_types(item_type)
      get("/itemTypeCreatorTypes", params: { itemType: item_type })
    end

    def new_item_template(item_type)
      get("/items/new", params: { itemType: item_type })
    end

    private

    attr_reader :api_key

    def auth_headers
      { "Zotero-API-Key" => api_key }
    end

    def default_headers
      { "Zotero-API-Version" => "3" }
    end

    def handle_response(response, format = nil)
      return parse_response_body(response, format) if response.code.between?(200, 299)

      raise_error_for_status(response)
    end

    def raise_error_for_status(response)
      case response.code
      when 400 then raise BadRequestError, "Bad request: #{response.body}"
      when 401, 403 then raise AuthenticationError, "Authentication failed - check your API key"
      when 404 then raise NotFoundError, "Resource not found: #{response.request.path}"
      when 429 then raise_rate_limit_error(response)
      else raise_server_or_unknown_error(response)
      end
    end

    def raise_rate_limit_error(response)
      backoff = response.headers["backoff"]&.to_i
      retry_after = response.headers["retry-after"]&.to_i
      message = "Rate limited."
      message += " Backoff: #{backoff}s" if backoff
      message += " Retry after: #{retry_after}s" if retry_after
      raise RateLimitError, message
    end

    def raise_server_or_unknown_error(response)
      case response.code
      when 500..599
        raise ServerError, "Server error: HTTP #{response.code} - #{response.message}"
      else
        raise Error, "Unexpected response: HTTP #{response.code} - #{response.message}"
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
