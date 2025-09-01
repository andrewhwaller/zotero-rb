# frozen_string_literal: true

RSpec.describe Zotero do
  it "has a version number" do
    expect(Zotero::VERSION).not_to be_nil
  end

  describe ".new" do
    it "creates a new client instance with API key" do
      client = described_class.new(api_key: "test_key")
      expect(client).to be_a(Zotero::Client)
    end
  end
end

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

  describe "#get" do
    it "makes HTTP GET requests with authentication headers" do
      # Stub the HTTParty request
      response = double("HTTParty::Response", code: 200, parsed_response: { "items" => [] })

      expect(described_class).to receive(:get).with(
        "/users/123/items",
        headers: { "Zotero-API-Key" => api_key }
      ).and_return(response)

      result = client.get("/users/123/items")
      expect(result).to eq({ "items" => [] })
    end

    it "raises error on 401 authentication failure" do
      response = double("HTTParty::Response", code: 401, message: "Unauthorized")

      allow(described_class).to receive(:get).and_return(response)

      expect do
        client.get("/users/123/items")
      end.to raise_error(Zotero::Error, /Authentication failed/)
    end

    it "raises error on 404 not found" do
      request = double("Request", path: "/users/123/items")
      response = double("HTTParty::Response", code: 404, message: "Not Found", request: request)

      allow(described_class).to receive(:get).and_return(response)

      expect do
        client.get("/users/123/items")
      end.to raise_error(Zotero::Error, /Resource not found/)
    end

    it "raises error on other HTTP errors" do
      response = double("HTTParty::Response", code: 500, message: "Internal Server Error")

      allow(described_class).to receive(:get).and_return(response)

      expect do
        client.get("/users/123/items")
      end.to raise_error(Zotero::Error, /HTTP 500/)
    end
  end
end
