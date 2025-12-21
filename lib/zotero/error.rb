# frozen_string_literal: true

module Zotero
  class Error < StandardError; end
  class AuthenticationError < Error; end

  # Raised when the API rate limit is exceeded
  class RateLimitError < Error
    attr_reader :retry_after, :backoff

    def initialize(message, retry_after: nil, backoff: nil)
      super(message)
      @retry_after = retry_after
      @backoff = backoff
    end

    def wait_time
      @retry_after || @backoff || 1
    end
  end

  class NotFoundError < Error; end
  class BadRequestError < Error; end
  class ServerError < Error; end
  class ConflictError < Error; end
  class PreconditionFailedError < Error; end
  class PreconditionRequiredError < Error; end
  class ParseError < Error; end
end
