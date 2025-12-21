# frozen_string_literal: true

module Zotero
  # Configuration for HTTP requests and retry behavior
  class HTTPConfig
    attr_accessor :open_timeout, :read_timeout, :verify_ssl,
                  :retry_on_rate_limit, :max_retries, :base_delay

    DEFAULTS = {
      open_timeout: 30,
      read_timeout: 60,
      verify_ssl: true,
      retry_on_rate_limit: true,
      max_retries: 3,
      base_delay: 1.0
    }.freeze

    def initialize(**options)
      config = DEFAULTS.merge(options)
      @open_timeout = config[:open_timeout]
      @read_timeout = config[:read_timeout]
      @verify_ssl = config[:verify_ssl]
      @retry_on_rate_limit = config[:retry_on_rate_limit]
      @max_retries = config[:max_retries]
      @base_delay = config[:base_delay]
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
