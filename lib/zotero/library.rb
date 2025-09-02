# frozen_string_literal: true

require_relative "library_file_operations"
require_relative "fulltext"
require_relative "syncing"

module Zotero
  class Library
    # TODO: rename this module, LibraryFileOperations sounds weird
    include LibraryFileOperations
    include Fulltext
    include Syncing

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
