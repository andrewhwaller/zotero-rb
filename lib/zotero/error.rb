# frozen_string_literal: true

module Zotero
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class RateLimitError < Error; end
  class NotFoundError < Error; end
  class BadRequestError < Error; end
  class ServerError < Error; end
end
