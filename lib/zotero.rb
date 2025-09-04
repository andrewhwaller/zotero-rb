# frozen_string_literal: true

require_relative "zotero/version"
require_relative "zotero/client"
require_relative "zotero/library"
require_relative "zotero/error"

# Ruby client library for the Zotero Web API v3.
#
# Provides a comprehensive interface for interacting with Zotero libraries,
# including full CRUD operations for items, collections, tags, searches,
# file uploads, and synchronization.
#
# @example Basic usage
#   client = Zotero.new(api_key: 'your-api-key')
#   library = client.user_library(12345)
#   items = library.items
#
# @see https://www.zotero.org/support/dev/web_api/v3/start Zotero Web API v3 Documentation
module Zotero
  # Create a new Zotero API client.
  #
  # @param api_key [String] Your Zotero API key
  # @return [Client] A new Zotero client instance
  def self.new(api_key:)
    Client.new(api_key: api_key)
  end
end
