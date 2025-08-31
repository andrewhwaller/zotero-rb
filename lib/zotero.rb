# frozen_string_literal: true

require_relative "zotero/version"
require_relative "zotero/client"
require_relative "zotero/error"

module Zotero
  class Error < StandardError; end

  def self.new(**options)
    Client.new(**options)
  end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :logger

    def initialize
      @base_url = "https://api.zotero.org"
      @timeout = 30
      @logger = nil
    end
  end
end
