# frozen_string_literal: true

require_relative "library_file_operations"
require_relative "fulltext"
require_relative "syncing"

module Zotero
  # Represents a Zotero library (user or group) and provides methods for
  # managing items, collections, tags, searches, and file operations.
  #
  # @example Working with a user library
  #   client = Zotero.new(api_key: 'your-key')
  #   library = client.user_library(12345)
  #   items = library.items
  #   collections = library.collections
  #
  class Library
    # TODO: rename this module, LibraryFileOperations sounds weird
    include LibraryFileOperations
    include Fulltext
    include Syncing

    VALID_TYPES = %w[user group].freeze

    # Initialize a new Library instance.
    #
    # @param client [Client] The Zotero client instance
    # @param type [String, Symbol] The library type (:user or :group)
    # @param id [Integer, String] The library ID (user ID or group ID)
    def initialize(client:, type:, id:)
      @client = client
      @type = validate_type(type)
      @id = id
      @base_path = "/#{@type}s/#{@id}"
    end

    # Get collections in this library.
    #
    # @param params [Hash] Query parameters for the request
    # @return [Array, Hash] Collections data from the API
    def collections(**params)
      @client.get("#{@base_path}/collections", params: params)
    end

    # Get items in this library.
    #
    # @param params [Hash] Query parameters for the request
    # @return [Array, Hash] Items data from the API
    def items(**params)
      @client.get("#{@base_path}/items", params: params)
    end

    def searches(**params)
      @client.get("#{@base_path}/searches", params: params)
    end

    def tags(**params)
      @client.get("#{@base_path}/tags", params: params)
    end

    # Create a new item in this library.
    #
    # @param item_data [Hash] The item data
    # @param version [Integer] Optional version for conditional requests
    # @param write_token [String] Optional write token for batch operations
    # @return [Hash] The API response
    def create_item(item_data, version: nil, write_token: nil)
      create_single("items", item_data, version: version, write_token: write_token)
    end

    def create_items(items_array, version: nil, write_token: nil)
      create_multiple("items", items_array, version: version, write_token: write_token)
    end

    def update_item(item_key, item_data, version: nil)
      @client.patch("#{@base_path}/items/#{item_key}", data: item_data, version: version)
    end

    def delete_item(item_key, version: nil)
      @client.delete("#{@base_path}/items/#{item_key}", version: version)
    end

    def delete_items(item_keys, version: nil)
      @client.delete("#{@base_path}/items", version: version, params: { itemKey: item_keys.join(",") })
    end

    def create_collection(collection_data, version: nil, write_token: nil)
      create_single("collections", collection_data, version: version, write_token: write_token)
    end

    def create_collections(collections_array, version: nil, write_token: nil)
      create_multiple("collections", collections_array, version: version, write_token: write_token)
    end

    def update_collection(collection_key, collection_data, version: nil)
      @client.patch("#{@base_path}/collections/#{collection_key}", data: collection_data, version: version)
    end

    def delete_collection(collection_key, version: nil)
      @client.delete("#{@base_path}/collections/#{collection_key}", version: version)
    end

    def delete_collections(collection_keys, version: nil)
      @client.delete("#{@base_path}/collections", version: version,
                                                  params: { collectionKey: collection_keys.join(",") })
    end

    private

    attr_reader :client, :type, :id, :base_path

    def create_single(resource, data, version: nil, write_token: nil)
      @client.post("#{@base_path}/#{resource}", data: [data], version: version, write_token: write_token)
    end

    def create_multiple(resource, data_array, version: nil, write_token: nil)
      @client.post("#{@base_path}/#{resource}", data: data_array, version: version, write_token: write_token)
    end

    def validate_type(type)
      type_str = type.to_s
      unless VALID_TYPES.include?(type_str)
        raise ArgumentError, "Invalid library type: #{type_str}. Must be one of: #{VALID_TYPES.join(', ')}"
      end

      type_str
    end
  end
end
