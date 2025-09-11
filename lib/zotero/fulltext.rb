# frozen_string_literal: true

module Zotero
  # Fulltext search and content methods
  module Fulltext
    # Get fulltext content that has been modified since a given version.
    #
    # @param since [Integer] Version number to get changes since
    # @return [Hash] Object mapping item keys to version numbers
    def fulltext_since(since:)
      params = { since: since }
      @client.make_get_request("#{@base_path}/fulltext", params: params)
    end

    # Get the fulltext content for a specific item.
    #
    # @param item_key [String] The item key to get fulltext for
    # @return [Hash] Fulltext content data including content, indexedChars, and totalChars
    def item_fulltext(item_key)
      @client.make_get_request("#{@base_path}/items/#{item_key}/fulltext")
    end

    # Set the fulltext content for a specific item.
    #
    # @param item_key [String] The item key to set fulltext for
    # @param content_data [Hash] Fulltext content data with content, indexedChars, totalChars
    # @param version [Integer] Optional version for optimistic concurrency control
    # @return [Boolean] Success status
    def set_item_fulltext(item_key, content_data, version: nil)
      @client.make_write_request(:put, "#{@base_path}/items/#{item_key}/fulltext", data: content_data,
                                                                                   options: { version: version })
    end
  end
end
