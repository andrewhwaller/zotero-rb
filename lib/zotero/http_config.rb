# frozen_string_literal: true

module Zotero
  # Configuration for HTTP requests
  class HTTPConfig
    attr_accessor :open_timeout, :read_timeout, :verify_ssl

    def initialize(open_timeout: 30, read_timeout: 60, verify_ssl: true)
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @verify_ssl = verify_ssl
    end

    def self.default
      @default ||= new
    end

    def self.configure
      yield(default) if block_given?
      default
    end
  end
end
