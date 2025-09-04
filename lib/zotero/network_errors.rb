# frozen_string_literal: true

require "socket"
require "openssl"

module Zotero
  # Handles network errors and translates them to appropriate Zotero exceptions
  module NetworkErrors
    ERROR_MESSAGES = {
      Errno::ECONNREFUSED => "Connection refused - server may be down",
      Errno::EHOSTUNREACH => "Host unreachable - check network connectivity",
      Errno::ENETUNREACH => "Host unreachable - check network connectivity",
      SocketError => "DNS resolution failed - check hostname",
      Net::OpenTimeout => "Connection timeout - server took too long to respond",
      Net::ReadTimeout => "Read timeout - server response was too slow",
      OpenSSL::SSL::SSLError => "SSL error - certificate verification failed",
      Timeout::Error => "Request timeout"
    }.freeze

    def handle_network_errors
      yield
    rescue *network_error_classes => e
      raise translate_network_error(e)
    end

    private

    def network_error_classes
      [
        Errno::ECONNREFUSED,
        Errno::EHOSTUNREACH,
        Errno::ENETUNREACH,
        SocketError,
        Net::OpenTimeout,
        Net::ReadTimeout,
        OpenSSL::SSL::SSLError,
        Timeout::Error
      ]
    end

    def translate_network_error(error)
      message = error_message_for(error)
      Error.new("#{message} (#{error.class})")
    end

    def error_message_for(error)
      ERROR_MESSAGES.fetch(error.class) { "Network error: #{error.message}" }
    end
  end
end
