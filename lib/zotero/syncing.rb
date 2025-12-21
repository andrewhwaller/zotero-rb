# frozen_string_literal: true

module Zotero
  # Syncing and API key verification methods.
  #
  # This module can be included in both Client and Library classes.
  # Classes including this module must implement #api_client which returns
  # the object that responds to #make_get_request.
  module Syncing
    # Verify that the current API key is valid.
    #
    # @return [Hash] API key information including userID and username
    def verify_api_key
      api_client.make_get_request("/keys/current")
    end

    # Get groups for a specific user.
    #
    # @param user_id [Integer, String] The user ID to get groups for
    # @param format [String] Response format ('versions' or 'json')
    # @return [Hash, Array] Groups data in the requested format
    def user_groups(user_id, format: "versions")
      api_client.make_get_request("/users/#{user_id}/groups", params: { format: format })
    end

    # Get items that have been deleted from this library.
    # Only available when included in Library.
    #
    # @param since [Integer] Optional version to get deletions since
    # @return [Hash] Object with deleted collections and items arrays
    def deleted_items(since: nil)
      api_client.make_get_request("#{@base_path}/deleted", params: { since: since }.compact)
    end

    private

    # Returns the object that handles API requests.
    # Override in including classes if needed.
    #
    # @return [Object] The API client object
    def api_client
      @client || self
    end
  end
end
