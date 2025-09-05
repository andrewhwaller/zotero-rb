# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::HTTPErrors do
  let(:test_class) { Class.new { include Zotero::HTTPErrors } }
  let(:instance) { test_class.new }

  describe "#raise_error_for_status" do
    it "raises client error for 400-428 range" do
      response = double("Response", code: "400", body: "Bad request")
      expect(instance).to receive(:raise_client_error).with(response)
      instance.raise_error_for_status(response)
    end

    it "raises rate limit error for 429" do
      response = double("Response", code: "429")
      expect(instance).to receive(:raise_rate_limit_error).with(response)
      instance.raise_error_for_status(response)
    end

    it "raises server or unknown error for other codes" do
      response = double("Response", code: "500")
      expect(instance).to receive(:raise_server_or_unknown_error).with(response)
      instance.raise_error_for_status(response)
    end
  end

  describe "#raise_client_error" do
    it "raises BadRequestError for 400" do
      response = double("Response", code: "400", body: "Invalid request")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::BadRequestError, /Bad request: Invalid request/)
    end

    it "raises BadRequestError for 413" do
      response = double("Response", code: "413", body: "Request too large")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::BadRequestError, /Bad request: Request too large/)
    end

    it "raises AuthenticationError for 401" do
      response = double("Response", code: "401", body: "Unauthorized")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::AuthenticationError, /Authentication failed/)
    end

    it "raises AuthenticationError for 403" do
      response = double("Response", code: "403", body: "Forbidden")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::AuthenticationError, /Authentication failed/)
    end

    it "raises NotFoundError for 404" do
      response = double("Response", code: "404", body: "Not found")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::NotFoundError, /Resource not found/)
    end

    it "raises ConflictError for 409" do
      response = double("Response", code: "409", body: "Library locked")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::ConflictError, /Conflict: Library locked/)
    end

    it "raises PreconditionFailedError for 412" do
      response = double("Response", code: "412", body: "Version mismatch")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::PreconditionFailedError, /Precondition failed: Version mismatch/)
    end

    it "raises PreconditionRequiredError for 428" do
      response = double("Response", code: "428", body: "Version required")
      expect { instance.raise_client_error(response) }
        .to raise_error(Zotero::PreconditionRequiredError, /Precondition required: Version required/)
    end
  end

  describe "#raise_rate_limit_error" do
    it "raises RateLimitError with basic message" do
      response = double("Response", code: "429", to_hash: {})
      expect { instance.raise_rate_limit_error(response) }
        .to raise_error(Zotero::RateLimitError, /Rate limited/)
    end

    it "includes backoff time when present" do
      response = double("Response", code: "429", to_hash: { "backoff" => ["30"] })
      expect { instance.raise_rate_limit_error(response) }
        .to raise_error(Zotero::RateLimitError, /Backoff: 30s/)
    end

    it "includes retry-after time when present" do
      response = double("Response", code: "429", to_hash: { "retry-after" => ["60"] })
      expect { instance.raise_rate_limit_error(response) }
        .to raise_error(Zotero::RateLimitError, /Retry after: 60s/)
    end

    it "includes both backoff and retry-after when both present" do
      response = double("Response", code: "429", to_hash: { "backoff" => ["30"], "retry-after" => ["60"] })
      expect { instance.raise_rate_limit_error(response) }
        .to raise_error(Zotero::RateLimitError, /Backoff: 30s.*Retry after: 60s/)
    end
  end

  describe "#raise_server_or_unknown_error" do
    it "raises ServerError for 5xx codes" do
      response = double("Response", code: "500", message: "Internal Server Error")
      expect { instance.raise_server_or_unknown_error(response) }
        .to raise_error(Zotero::ServerError, /Server error: HTTP 500 - Internal Server Error/)
    end

    it "raises generic Error for unknown codes" do
      response = double("Response", code: "999", message: "Unknown")
      expect { instance.raise_server_or_unknown_error(response) }
        .to raise_error(Zotero::Error, /Unexpected response: HTTP 999 - Unknown/)
    end
  end
end
