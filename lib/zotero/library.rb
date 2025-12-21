# frozen_string_literal: true

require_relative "file_attachments"
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
    include FileAttachments
    include Fulltext
    include Syncing

    VALID_TYPES = %w[user group].freeze

    # Initialize a new Library instance.
    #
    # @param client [Client] The Zotero client instance
    # @param type [String, Symbol] The library type (:user or :group)
    # @param id [Integer, String] The library ID (user ID or group ID)
    # @raise [ArgumentError] if type is invalid or id is not a positive integer
    def initialize(client:, type:, id:)
      @client = client
      @type = validate_type(type)
      @id = validate_id(id)
      @base_path = "/#{@type}s/#{@id}"
    end

    # Get collections in this library.
    #
    # @param params [Hash] Query parameters for the request
    # @return [Array, Hash] Collections data from the API
    def collections(**params)
      client.make_get_request("#{base_path}/collections", params: params)
    end

    # Get items in this library.
    #
    # @param params [Hash] Query parameters for the request
    # @return [Array, Hash] Items data from the API
    def items(**params)
      client.make_get_request("#{base_path}/items", params: params)
    end

    # Get saved searches in this library.
    #
    # @param params [Hash] Query parameters for the request
    # @return [Array, Hash] Saved searches data from the API
    def searches(**params)
      client.make_get_request("#{base_path}/searches", params: params)
    end

    # Get tags in this library.
    #
    # @param params [Hash] Query parameters for the request
    # @return [Array, Hash] Tags data from the API
    def tags(**params)
      client.make_get_request("#{base_path}/tags", params: params)
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

    # Create multiple items in this library.
    #
    # @param items_array [Array<Hash>] Array of item data objects
    # @param version [Integer] Optional version for conditional requests
    # @param write_token [String] Optional write token for batch operations
    # @return [Hash] The API response with created items
    def create_items(items_array, version: nil, write_token: nil)
      create_multiple("items", items_array, version: version, write_token: write_token)
    end

    # Update an existing item in this library.
    #
    # @param item_key [String] The item key to update
    # @param item_data [Hash] The updated item data
    # @param version [Integer] Version for optimistic concurrency control
    # @return [Hash] The API response
    def update_item(item_key, item_data, version: nil)
      client.make_write_request(:patch, "#{base_path}/items/#{item_key}", data: item_data,
                                                                          options: { version: version })
    end

    # Delete an item from this library.
    #
    # @param item_key [String] The item key to delete
    # @param version [Integer] Version for optimistic concurrency control
    # @return [Boolean] Success status
    def delete_item(item_key, version: nil)
      client.make_write_request(:delete, "#{base_path}/items/#{item_key}", options: { version: version })
    end

    # Delete multiple items from this library.
    #
    # @param item_keys [Array<String>] Array of item keys to delete
    # @param version [Integer] Version for optimistic concurrency control
    # @return [Boolean] Success status
    def delete_items(item_keys, version: nil)
      client.make_write_request(:delete, "#{base_path}/items", options: { version: version },
                                                               params: { itemKey: item_keys.join(",") })
    end

    # Create a new collection in this library.
    #
    # @param collection_data [Hash] The collection data
    # @param version [Integer] Optional version for conditional requests
    # @param write_token [String] Optional write token for batch operations
    # @return [Hash] The API response
    def create_collection(collection_data, version: nil, write_token: nil)
      create_single("collections", collection_data, version: version, write_token: write_token)
    end

    # Create multiple collections in this library.
    #
    # @param collections_array [Array<Hash>] Array of collection data objects
    # @param version [Integer] Optional version for conditional requests
    # @param write_token [String] Optional write token for batch operations
    # @return [Hash] The API response with created collections
    def create_collections(collections_array, version: nil, write_token: nil)
      create_multiple("collections", collections_array, version: version, write_token: write_token)
    end

    # Update an existing collection in this library.
    #
    # @param collection_key [String] The collection key to update
    # @param collection_data [Hash] The updated collection data
    # @param version [Integer] Version for optimistic concurrency control
    # @return [Hash] The API response
    def update_collection(collection_key, collection_data, version: nil)
      client.make_write_request(:patch, "#{base_path}/collections/#{collection_key}", data: collection_data,
                                                                                      options: { version: version })
    end

    # Delete a collection from this library.
    #
    # @param collection_key [String] The collection key to delete
    # @param version [Integer] Version for optimistic concurrency control
    # @return [Boolean] Success status
    def delete_collection(collection_key, version: nil)
      client.make_write_request(:delete, "#{base_path}/collections/#{collection_key}", options: { version: version })
    end

    # Delete multiple collections from this library.
    #
    # @param collection_keys [Array<String>] Array of collection keys to delete
    # @param version [Integer] Version for optimistic concurrency control
    # @return [Boolean] Success status
    def delete_collections(collection_keys, version: nil)
      client.make_write_request(:delete, "#{base_path}/collections",
                                options: { version: version },
                                params: { collectionKey: collection_keys.join(",") })
    end

    private

    attr_reader :client, :type, :id, :base_path

    def create_single(resource, data, version: nil, write_token: nil)
      client.make_write_request(:post, "#{base_path}/#{resource}",
                                data: [data],
                                options: { version: version, write_token: write_token })
    end

    def create_multiple(resource, data_array, version: nil, write_token: nil)
      client.make_write_request(:post, "#{base_path}/#{resource}",
                                data: data_array,
                                options: { version: version, write_token: write_token })
    end

    def validate_type(type)
      type_str = type.to_s
      unless VALID_TYPES.include?(type_str)
        raise ArgumentError, "Invalid library type: #{type_str}. Must be one of: #{VALID_TYPES.join(', ')}"
      end

      type_str
    end

    def validate_id(id)
      id_int = Integer(id, exception: false)
      raise ArgumentError, "Invalid library ID: #{id.inspect}. Must be a positive integer" unless id_int&.positive?

      id_int
    end
  end
end
