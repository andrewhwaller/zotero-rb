# frozen_string_literal: true

module Zotero
  module Fulltext
    def fulltext_since(since:)
      @client.get("#{@base_path}/fulltext", params: { since: since })
    end

    def item_fulltext(item_key)
      @client.get("#{@base_path}/items/#{item_key}/fulltext")
    end

    def set_item_fulltext(item_key, content_data, version: nil)
      @client.put("#{@base_path}/items/#{item_key}/fulltext", data: content_data, version: version)
    end
  end
end
