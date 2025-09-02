# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }

  describe "#initialize" do
    it "requires an api_key" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it "accepts an api_key" do
      expect { described_class.new(api_key: api_key) }.not_to raise_error
    end
  end

  describe "HTTP methods integration" do
    describe "#get" do
      it "makes HTTP GET requests with authentication and version headers" do
        response = double("HTTParty::Response", code: 200, parsed_response: { "items" => [] }, headers: {})

        expect(described_class).to receive(:get).with(
          "/users/123/items",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: {}
        ).and_return(response)

        result = client.get("/users/123/items")
        expect(result).to eq({ "items" => [] })
      end

      it "accepts query parameters" do
        response = double("HTTParty::Response", code: 200, parsed_response: [], body: "ABC123\nDEF456", headers: {})

        expect(described_class).to receive(:get).with(
          "/users/123/items",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: { limit: 10, format: "keys" }
        ).and_return(response)

        client.get("/users/123/items", params: { limit: 10, format: "keys" })
      end

      it "returns raw body for non-json formats" do
        response = double("HTTParty::Response", code: 200, body: "ABC123\nDEF456\n\n")

        allow(described_class).to receive(:get).and_return(response)

        result = client.get("/users/123/items", params: { format: "keys" })
        expect(result).to eq("ABC123\nDEF456\n\n")
      end
    end

    describe "#post" do
      it "makes POST requests with write headers" do
        response = double("HTTParty::Response", code: 200, parsed_response: { "success" => { "0" => "ABC123" } })
        data = [{ itemType: "book", title: "Test Book" }]

        expect(described_class).to receive(:post).with(
          "/users/123/items",
          headers: {
            "Zotero-API-Key" => api_key,
            "Zotero-API-Version" => "3",
            "Content-Type" => "application/json",
            "If-Unmodified-Since-Version" => "150"
          },
          body: data,
          query: {}
        ).and_return(response)

        result = client.post("/users/123/items", data: data, version: 150)
        expect(result["success"]["0"]).to eq("ABC123")
      end

      it "includes write token when provided" do
        response = double("HTTParty::Response", code: 200, parsed_response: {})
        data = [{ itemType: "book" }]

        expect(described_class).to receive(:post).with(
          "/users/123/items",
          headers: hash_including("Zotero-Write-Token" => "abc123"),
          body: data,
          query: {}
        ).and_return(response)

        client.post("/users/123/items", data: data, write_token: "abc123")
      end
    end

    describe "#put" do
      it "makes PUT requests with write headers" do
        response = double("HTTParty::Response", code: 200, parsed_response: { "updated" => true })
        data = { title: "Updated Title" }

        expect(described_class).to receive(:put).with(
          "/users/123/items/ABC123",
          headers: {
            "Zotero-API-Key" => api_key,
            "Zotero-API-Version" => "3",
            "Content-Type" => "application/json",
            "If-Unmodified-Since-Version" => "150"
          },
          body: data,
          query: {}
        ).and_return(response)

        result = client.put("/users/123/items/ABC123", data: data, version: 150)
        expect(result).to eq({ "updated" => true })
      end
    end

    describe "#patch" do
      it "makes PATCH requests with version header" do
        response = double("HTTParty::Response", code: 204)
        data = { title: "Updated Title" }

        expect(described_class).to receive(:patch).with(
          "/users/123/items/ABC123",
          headers: {
            "Zotero-API-Key" => api_key,
            "Zotero-API-Version" => "3",
            "Content-Type" => "application/json",
            "If-Unmodified-Since-Version" => "150"
          },
          body: data,
          query: {}
        ).and_return(response)

        result = client.patch("/users/123/items/ABC123", data: data, version: 150)
        expect(result).to be true
      end
    end

    describe "#delete" do
      it "makes DELETE requests with version header" do
        response = double("HTTParty::Response", code: 204)

        expect(described_class).to receive(:delete).with(
          "/users/123/items/ABC123",
          headers: {
            "Zotero-API-Key" => api_key,
            "Zotero-API-Version" => "3",
            "Content-Type" => "application/json",
            "If-Unmodified-Since-Version" => "150"
          },
          query: {}
        ).and_return(response)

        result = client.delete("/users/123/items/ABC123", version: 150)
        expect(result).to be true
      end
    end
  end

  describe "error handling integration" do
    it "raises AuthenticationError on 401 authentication failure" do
      response = double("HTTParty::Response", code: 401, message: "Unauthorized")

      allow(described_class).to receive(:get).and_return(response)

      expect do
        client.get("/users/123/items")
      end.to raise_error(Zotero::AuthenticationError, /Authentication failed/)
    end

    it "raises NotFoundError on 404 not found" do
      request = double("Request", path: "/users/123/items")
      response = double("HTTParty::Response", code: 404, message: "Not Found", request: request)

      allow(described_class).to receive(:get).and_return(response)

      expect do
        client.get("/users/123/items")
      end.to raise_error(Zotero::NotFoundError, /Resource not found/)
    end

    it "raises ServerError on 500 server errors" do
      response = double("HTTParty::Response", code: 500, message: "Internal Server Error")

      allow(described_class).to receive(:get).and_return(response)

      expect do
        client.get("/users/123/items")
      end.to raise_error(Zotero::ServerError, /Server error: HTTP 500/)
    end
  end

  describe "library factory methods" do
    describe "#user_library" do
      it "returns a Library instance for user libraries" do
        library = client.user_library(123)
        expect(library).to be_a(Zotero::Library)
        expect(library.instance_variable_get(:@type)).to eq("user")
        expect(library.instance_variable_get(:@id)).to eq(123)
      end
    end

    describe "#group_library" do
      it "returns a Library instance for group libraries" do
        library = client.group_library(456)
        expect(library).to be_a(Zotero::Library)
        expect(library.instance_variable_get(:@type)).to eq("group")
        expect(library.instance_variable_get(:@id)).to eq(456)
      end
    end
  end
end
