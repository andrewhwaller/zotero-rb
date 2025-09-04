# frozen_string_literal: true

require "net/http"
require "openssl"

module Zotero
  # Manages HTTP connections with proper SSL configuration and timeouts
  class HTTPConnection
    DEFAULT_OPEN_TIMEOUT = 30
    DEFAULT_READ_TIMEOUT = 60

    def initialize(uri, config = nil)
      @uri = uri
      @config = config || HTTPConfig.default
      @http = build_connection
    end

    def request(net_request)
      configure_connection unless @configured
      @http.request(net_request)
    end

    private

    attr_reader :uri, :config, :http

    def build_connection
      Net::HTTP.new(@uri.host, @uri.port)
    end

    def configure_connection
      configure_ssl if @uri.scheme == "https"
      configure_timeouts
      @configured = true
    end

    def configure_ssl
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @http.ca_file = OpenSSL::X509::DEFAULT_CERT_FILE
    end

    def configure_timeouts
      @http.open_timeout = @config.open_timeout
      @http.read_timeout = @config.read_timeout
    end
  end
end
