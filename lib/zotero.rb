# frozen_string_literal: true

require_relative "zotero/version"
require_relative "zotero/client"
require_relative "zotero/error"

module Zotero
  def self.new(api_key:)
    Client.new(api_key: api_key)
  end
end
