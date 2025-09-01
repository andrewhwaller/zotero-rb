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
    it "makes HTTP GET requests with authentication and version headers" do
      # Stub the HTTParty request
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

    it "passes all parameters to the API" do
      response = double("HTTParty::Response", code: 200, parsed_response: [], headers: {})

      expect(described_class).to receive(:get).with(
        "/users/123/items",
        headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
        query: { limit: 10, invalid_param: "test" }
      ).and_return(response)

      client.get("/users/123/items", params: { limit: 10, invalid_param: "test" })
    end

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

    it "returns raw body for non-json formats" do
      response = double("HTTParty::Response", code: 200, body: "ABC123\nDEF456\n\n")

      allow(described_class).to receive(:get).and_return(response)

      result = client.get("/users/123/items", params: { format: "keys" })
      expect(result).to eq("ABC123\nDEF456\n\n")
    end
  end

  describe "#user_library" do
    it "returns a Library instance for user libraries" do
      library = client.user_library(123)
      expect(library).to be_a(Zotero::Library)
    end
  end

  describe "#group_library" do
    it "returns a Library instance for group libraries" do
      library = client.group_library(456)
      expect(library).to be_a(Zotero::Library)
    end
  end

  describe "schema methods" do
    describe "#item_types" do
      it "calls the correct endpoint without locale" do
        response = double("HTTParty::Response", code: 200, parsed_response: [])

        expect(described_class).to receive(:get).with(
          "/itemTypes",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: {}
        ).and_return(response)

        client.item_types
      end

      it "calls the correct endpoint with locale" do
        response = double("HTTParty::Response", code: 200, parsed_response: [])

        expect(described_class).to receive(:get).with(
          "/itemTypes",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: { locale: "fr-FR" }
        ).and_return(response)

        client.item_types(locale: "fr-FR")
      end
    end

    describe "#item_fields" do
      it "calls the correct endpoint" do
        response = double("HTTParty::Response", code: 200, parsed_response: [])

        expect(described_class).to receive(:get).with(
          "/itemFields",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: {}
        ).and_return(response)

        client.item_fields
      end
    end

    describe "#item_type_fields" do
      it "calls the correct endpoint with required itemType" do
        response = double("HTTParty::Response", code: 200, parsed_response: [])

        expect(described_class).to receive(:get).with(
          "/itemTypeFields",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: { itemType: "book" }
        ).and_return(response)

        client.item_type_fields("book")
      end

      it "calls the correct endpoint with locale" do
        response = double("HTTParty::Response", code: 200, parsed_response: [])

        expect(described_class).to receive(:get).with(
          "/itemTypeFields",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: { itemType: "book", locale: "fr-FR" }
        ).and_return(response)

        client.item_type_fields("book", locale: "fr-FR")
      end
    end

    describe "#creator_fields" do
      it "calls the correct endpoint" do
        response = double("HTTParty::Response", code: 200, parsed_response: [])

        expect(described_class).to receive(:get).with(
          "/creatorFields",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: {}
        ).and_return(response)

        client.creator_fields
      end
    end

    describe "#item_type_creator_types" do
      it "calls the correct endpoint" do
        response = double("HTTParty::Response", code: 200, parsed_response: [])

        expect(described_class).to receive(:get).with(
          "/itemTypeCreatorTypes",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: { itemType: "book" }
        ).and_return(response)

        client.item_type_creator_types("book")
      end
    end

    describe "#new_item_template" do
      it "calls the correct endpoint" do
        response = double("HTTParty::Response", code: 200, parsed_response: {})

        expect(described_class).to receive(:get).with(
          "/items/new",
          headers: { "Zotero-API-Key" => api_key, "Zotero-API-Version" => "3" },
          query: { itemType: "book" }
        ).and_return(response)

        client.new_item_template("book")
      end
    end
  end
end

RSpec.describe Zotero::Library do
  let(:api_key) { "test_api_key" }
  let(:client) { Zotero::Client.new(api_key: api_key) }
  let(:user_library) { described_class.new(client: client, type: :user, id: 123) }
  let(:group_library) { described_class.new(client: client, type: :group, id: 456) }

  describe "#initialize" do
    it "validates library type" do
      expect do
        described_class.new(client: client, type: :invalid, id: 123)
      end.to raise_error(ArgumentError, /Invalid library type/)
    end

    it "accepts user type" do
      expect { user_library }.not_to raise_error
    end

    it "accepts group type" do
      expect { group_library }.not_to raise_error
    end
  end

  describe "resource methods" do
    it "#collections calls the correct endpoint" do
      expect(client).to receive(:get).with("/users/123/collections", params: {})
      user_library.collections
    end

    it "#items calls the correct endpoint" do
      expect(client).to receive(:get).with("/groups/456/items", params: { limit: 10 })
      group_library.items(limit: 10)
    end

    it "#searches calls the correct endpoint" do
      expect(client).to receive(:get).with("/users/123/searches", params: {})
      user_library.searches
    end

    it "#tags calls the correct endpoint" do
      expect(client).to receive(:get).with("/users/123/tags", params: {})
      user_library.tags
    end
  end
end
