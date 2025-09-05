# frozen_string_literal: true

module Zotero
  # HTTP error handling methods
  module HTTPErrors
    def raise_error_for_status(response)
      code = response.code.to_i
      case code
      when 400..428 then raise_client_error(response)
      when 429 then raise_rate_limit_error(response)
      else raise_server_or_unknown_error(response)
      end
    end

    def raise_client_error(response)
      code = response.code.to_i
      case code
      when 400, 413 then raise BadRequestError, "Bad request: #{response.body}"
      when 401, 403 then raise AuthenticationError, "Authentication failed - check your API key"
      when 404 then raise NotFoundError, "Resource not found"
      when 409 then raise ConflictError, "Conflict: #{response.body}"
      when 412 then raise PreconditionFailedError, "Precondition failed: #{response.body}"
      when 428 then raise PreconditionRequiredError, "Precondition required: #{response.body}"
      end
    end

    def raise_rate_limit_error(response)
      headers = response.to_hash.transform_values(&:first)
      backoff = headers["backoff"]&.to_i
      retry_after = headers["retry-after"]&.to_i
      message = "Rate limited."
      message += " Backoff: #{backoff}s" if backoff
      message += " Retry after: #{retry_after}s" if retry_after
      raise RateLimitError, message
    end

    def raise_server_or_unknown_error(response)
      code = response.code.to_i
      case code
      when 500..599
        raise ServerError, "Server error: HTTP #{code} - #{response.message}"
      else
        raise Error, "Unexpected response: HTTP #{code} - #{response.message}"
      end
    end
  end
end
