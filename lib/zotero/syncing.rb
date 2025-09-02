# frozen_string_literal: true

module Zotero
  module Syncing
    def verify_api_key
      @client ? @client.get("/keys/current") : get("/keys/current")
    end

    def user_groups(user_id, format: "versions")
      client = @client || self
      client.get("/users/#{user_id}/groups", params: { format: format })
    end

    def deleted_items(since: nil)
      params = since ? { since: since } : {}
      @client.get("#{@base_path}/deleted", params: params)
    end
  end
end
