# frozen_string_literal: true

module Zotero
  # Syncing and API key verification methods
  module Syncing
    # Verify that the current API key is valid.
    #
    # @return [Hash] API key information including userID and username
    def verify_api_key
      if @client
        @client.make_get_request("/keys/current")
      else
        make_get_request("/keys/current")
      end
    end

    # Get groups for a specific user.
    #
    # @param user_id [Integer, String] The user ID to get groups for
    # @param format [String] Response format ('versions' or 'json')
    # @return [Hash, Array] Groups data in the requested format
    def user_groups(user_id, format: "versions")
      params = { format: format }
      if @client
        @client.make_get_request("/users/#{user_id}/groups", params: params)
      else
        make_get_request("/users/#{user_id}/groups", params: params)
      end
    end

    # Get items that have been deleted from this library.
    #
    # @param since [Integer] Optional version to get deletions since
    # @return [Hash] Object with deleted collections and items arrays
    def deleted_items(since: nil)
      params = since ? { since: since } : {}
      @client.make_get_request("#{@base_path}/deleted", params: params)
    end
  end
end
