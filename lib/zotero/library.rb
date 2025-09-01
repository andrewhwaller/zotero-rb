# frozen_string_literal: true

module Zotero
  class Library
    VALID_TYPES = %w[user group].freeze

    def initialize(client:, type:, id:)
      @client = client
      @type = validate_type(type)
      @id = id
      @base_path = "/#{@type}s/#{@id}"
    end

    def collections(**params)
      @client.get("#{@base_path}/collections", params: params)
    end

    def items(**params)
      @client.get("#{@base_path}/items", params: params)
    end

    def searches(**params)
      @client.get("#{@base_path}/searches", params: params)
    end

    def tags(**params)
      @client.get("#{@base_path}/tags", params: params)
    end

    private

    attr_reader :client, :type, :id, :base_path

    def validate_type(type)
      type_str = type.to_s
      unless VALID_TYPES.include?(type_str)
        raise ArgumentError, "Invalid library type: #{type_str}. Must be one of: #{VALID_TYPES.join(', ')}"
      end

      type_str
    end
  end
end
