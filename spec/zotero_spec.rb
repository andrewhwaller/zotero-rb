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

  describe "write methods" do
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

    describe "#patch" do
      it "makes PATCH requests with version header" do
        response = double("HTTParty::Response", code: 200, parsed_response: {})
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

        client.patch("/users/123/items/ABC123", data: data, version: 150)
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

    describe "error handling" do
      it "raises ConflictError on 409" do
        response = double("HTTParty::Response", code: 409, body: "Library locked")

        allow(described_class).to receive(:post).and_return(response)

        expect do
          client.post("/users/123/items", data: [{}])
        end.to raise_error(Zotero::ConflictError, /Conflict: Library locked/)
      end

      it "raises PreconditionFailedError on 412" do
        response = double("HTTParty::Response", code: 412, body: "Version mismatch")

        allow(described_class).to receive(:patch).and_return(response)

        expect do
          client.patch("/users/123/items/ABC123", data: {})
        end.to raise_error(Zotero::PreconditionFailedError, /Precondition failed: Version mismatch/)
      end

      it "raises PreconditionRequiredError on 428" do
        response = double("HTTParty::Response", code: 428, body: "Version required")

        allow(described_class).to receive(:post).and_return(response)

        expect do
          client.post("/users/123/items", data: [{}])
        end.to raise_error(Zotero::PreconditionRequiredError, /Precondition required: Version required/)
      end
    end

    describe "file upload methods" do
      describe "#post_form" do
        it "makes form-encoded POST requests" do
          form_data = { upload: "test.pdf", md5: "abc123" }

          expect(described_class).to receive(:post).with(
            "/users/123/items/ABC123/file",
            headers: {
              "Zotero-API-Key" => api_key,
              "Zotero-API-Version" => "3",
              "Content-Type" => "application/x-www-form-urlencoded",
              "If-None-Match" => "*"
            },
            body: form_data,
            query: {}
          ).and_return(double("HTTParty::Response", code: 200, parsed_response: {}))

          client.post_form("/users/123/items/ABC123/file", form_data: form_data, if_none_match: "*")
        end
      end

      describe "#external_post" do
        it "makes multipart POST to external URL" do
          multipart_data = { file: "data", key: "value" }
          response = double("HTTParty::Response", code: 200, body: "OK")

          expect(described_class).to receive(:post).with(
            "https://s3.amazonaws.com/upload",
            body: multipart_data,
            multipart: true,
            format: :plain
          ).and_return(response)

          result = client.external_post("https://s3.amazonaws.com/upload", multipart_data: multipart_data)
          expect(result).to eq("OK")
        end

        it "raises error on upload failure" do
          response = double("HTTParty::Response", code: 500, message: "Server Error")

          expect(described_class).to receive(:post).and_return(response)

          expect do
            client.external_post("https://s3.amazonaws.com/upload", multipart_data: {})
          end.to raise_error(Zotero::Error, /External upload failed: HTTP 500/)
        end
      end

      describe "#request_upload_authorization" do
        it "makes form request for new file upload" do
          expect(client).to receive(:post_form).with(
            "/users/123/items/ABC123/file",
            form_data: { upload: "test.pdf", md5: "abc123", mtime: 1_234_567_890 },
            if_none_match: "*"
          )

          client.request_upload_authorization(
            "/users/123/items/ABC123/file",
            filename: "test.pdf",
            md5: "abc123",
            mtime: 1_234_567_890
          )
        end

        it "makes form request for existing file update" do
          expect(client).to receive(:post_form).with(
            "/users/123/items/ABC123/file",
            form_data: { upload: "test.pdf", md5: "new_hash" },
            if_match: "new_hash"
          )

          client.request_upload_authorization(
            "/users/123/items/ABC123/file",
            filename: "test.pdf",
            md5: "new_hash",
            existing_file: true
          )
        end
      end

      describe "#register_upload" do
        it "registers upload completion with upload key" do
          expect(client).to receive(:post_form).with(
            "/users/123/items/ABC123/file",
            form_data: { upload: "upload_key_123" }
          )

          client.register_upload("/users/123/items/ABC123/file", upload_key: "upload_key_123")
        end
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

  describe "write methods" do
    describe "item operations" do
      it "#create_item wraps single item in array" do
        item_data = { itemType: "book", title: "Test" }
        expect(client).to receive(:post).with("/users/123/items", data: [item_data], version: 150, write_token: nil)
        user_library.create_item(item_data, version: 150)
      end

      it "#create_items passes array directly" do
        items = [{ itemType: "book" }, { itemType: "article" }]
        expect(client).to receive(:post).with("/users/123/items", data: items, version: nil, write_token: "token123")
        user_library.create_items(items, write_token: "token123")
      end

      it "#update_item calls patch with correct path" do
        item_data = { title: "Updated Title" }
        expect(client).to receive(:patch).with("/users/123/items/ABC123", data: item_data, version: 150)
        user_library.update_item("ABC123", item_data, version: 150)
      end

      it "#delete_item calls delete with item key" do
        expect(client).to receive(:delete).with("/users/123/items/ABC123", version: 150)
        user_library.delete_item("ABC123", version: 150)
      end

      it "#delete_items joins item keys for bulk delete" do
        expect(client).to receive(:delete).with("/users/123/items",
                                                version: 150,
                                                params: { itemKey: "ABC123,DEF456" })
        user_library.delete_items(%w[ABC123 DEF456], version: 150)
      end
    end

    describe "collection operations" do
      it "#create_collection wraps single collection in array" do
        collection_data = { name: "Test Collection" }
        expect(client).to receive(:post).with("/users/123/collections", data: [collection_data], version: 150,
                                                                        write_token: nil)
        user_library.create_collection(collection_data, version: 150)
      end

      it "#create_collections passes array directly" do
        collections = [{ name: "Collection 1" }, { name: "Collection 2" }]
        expect(client).to receive(:post).with("/users/123/collections", data: collections, version: nil,
                                                                        write_token: "token123")
        user_library.create_collections(collections, write_token: "token123")
      end

      it "#update_collection calls patch with correct path" do
        collection_data = { name: "Updated Name" }
        expect(client).to receive(:patch).with("/users/123/collections/XYZ789", data: collection_data, version: 150)
        user_library.update_collection("XYZ789", collection_data, version: 150)
      end

      it "#delete_collection calls delete with collection key" do
        expect(client).to receive(:delete).with("/users/123/collections/XYZ789", version: 150)
        user_library.delete_collection("XYZ789", version: 150)
      end

      it "#delete_collections joins collection keys for bulk delete" do
        expect(client).to receive(:delete).with("/users/123/collections",
                                                version: 150,
                                                params: { collectionKey: "XYZ789,ABC123" })
        user_library.delete_collections(%w[XYZ789 ABC123], version: 150)
      end
    end

    describe "file upload operations" do
      it "#create_attachment wraps single attachment in array" do
        attachment_data = { itemType: "attachment", contentType: "application/pdf" }
        expect(client).to receive(:post).with("/users/123/items", data: [attachment_data], version: 150,
                                                                  write_token: nil)
        user_library.create_attachment(attachment_data, version: 150)
      end

      it "#get_file_info calls correct endpoint" do
        expect(client).to receive(:get).with("/users/123/items/ABC123/file")
        user_library.get_file_info("ABC123")
      end

      describe "#upload_file" do
        let(:file_path) { "/tmp/test.pdf" }
        let(:auth_response) { { "url" => "https://s3.amazonaws.com/upload", "uploadKey" => "abc123" } }

        before do
          allow(File).to receive(:basename).with(file_path).and_return("test.pdf")
          allow(File).to receive(:mtime).with(file_path).and_return(Time.at(1_234_567_890))
          allow(Digest::MD5).to receive(:file).with(file_path).and_return(double(hexdigest: "abc123hash"))
          allow(user_library).to receive(:build_upload_params).and_return({ file: "data" })
        end

        it "orchestrates the 3-step upload process" do
          expect(client).to receive(:request_upload_authorization).with(
            "/users/123/items/ABC123/file",
            filename: "test.pdf",
            md5: "abc123hash",
            mtime: 1_234_567_890_000,
            existing_file: false
          ).and_return(auth_response)

          expect(client).to receive(:external_post).with(
            "https://s3.amazonaws.com/upload",
            multipart_data: { file: "data" }
          )

          expect(client).to receive(:register_upload).with(
            "/users/123/items/ABC123/file",
            upload_key: "abc123"
          )

          user_library.upload_file("ABC123", file_path)
        end

        it "handles direct upload without registration" do
          direct_response = { "url" => "https://direct.zotero.org/upload" }

          expect(client).to receive(:request_upload_authorization).and_return(direct_response)
          expect(client).to receive(:external_post)
          expect(client).not_to receive(:register_upload)

          result = user_library.upload_file("ABC123", file_path)
          expect(result).to be true
        end
      end

      describe "#update_file" do
        let(:file_path) { "/tmp/updated.pdf" }
        let(:current_md5) { "old_hash" }

        before do
          allow(File).to receive(:basename).with(file_path).and_return("updated.pdf")
          allow(File).to receive(:mtime).with(file_path).and_return(Time.at(1_234_567_890))
          allow(Digest::MD5).to receive(:file).with(file_path).and_return(double(hexdigest: "new_hash"))
        end

        it "uses existing_file: true for upload authorization" do
          expect(client).to receive(:request_upload_authorization).with(
            "/users/123/items/ABC123/file",
            filename: "updated.pdf",
            md5: "new_hash",
            mtime: 1_234_567_890_000,
            existing_file: true
          ).and_return({})

          user_library.update_file("ABC123", file_path)
        end
      end
    end

    describe "Fulltext operations" do
      describe "#fulltext_since" do
        it "calls the correct endpoint with since parameter" do
          expect(client).to receive(:get).with("/users/123/fulltext", params: { since: 100 })
          user_library.fulltext_since(since: 100)
        end

        it "requires the since parameter" do
          expect { user_library.fulltext_since }.to raise_error(ArgumentError)
        end
      end

      describe "#item_fulltext" do
        it "calls the correct endpoint for specific item" do
          expect(client).to receive(:get).with("/users/123/items/ABC123/fulltext")
          user_library.item_fulltext("ABC123")
        end
      end

      describe "#set_item_fulltext" do
        let(:content_data) do
          {
            "content" => "This is full-text content.",
            "indexedChars" => 26,
            "totalChars" => 26
          }
        end

        it "calls PUT with content data" do
          expect(client).to receive(:put).with(
            "/users/123/items/ABC123/fulltext",
            data: content_data,
            version: nil
          )
          user_library.set_item_fulltext("ABC123", content_data)
        end

        it "accepts version parameter" do
          expect(client).to receive(:put).with(
            "/users/123/items/ABC123/fulltext",
            data: content_data,
            version: 42
          )
          user_library.set_item_fulltext("ABC123", content_data, version: 42)
        end
      end
    end
  end
end
