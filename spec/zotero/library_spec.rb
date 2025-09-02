# frozen_string_literal: true

require "spec_helper"

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

    it "sets base path correctly for user library" do
      expect(user_library.instance_variable_get(:@base_path)).to eq("/users/123")
    end

    it "sets base path correctly for group library" do
      expect(group_library.instance_variable_get(:@base_path)).to eq("/groups/456")
    end

    it "converts type to string" do
      expect(user_library.instance_variable_get(:@type)).to eq("user")
      expect(group_library.instance_variable_get(:@type)).to eq("group")
    end
  end

  describe "basic resource methods integration" do
    it "#collections delegates to client with correct path" do
      collections_response = [{ "key" => "ABC123", "data" => { "name" => "My Collection" } }]
      expect(client).to receive(:get).with("/users/123/collections", params: {}).and_return(collections_response)

      result = user_library.collections
      expect(result).to eq(collections_response)
    end

    it "#items delegates to client with parameters" do
      items_response = [{ "key" => "DEF456", "data" => { "title" => "Sample Book" } }]
      expect(client).to receive(:get).with("/groups/456/items", params: { limit: 10 }).and_return(items_response)

      result = group_library.items(limit: 10)
      expect(result).to eq(items_response)
    end

    it "#searches delegates to client with correct path" do
      searches_response = [{ "key" => "GHI789", "data" => { "name" => "My Search" } }]
      expect(client).to receive(:get).with("/users/123/searches", params: {}).and_return(searches_response)

      result = user_library.searches
      expect(result).to eq(searches_response)
    end

    it "#tags delegates to client with correct path" do
      tags_response = [{ "tag" => "important", "meta" => { "numItems" => 5 } }]
      expect(client).to receive(:get).with("/users/123/tags", params: {}).and_return(tags_response)

      result = user_library.tags
      expect(result).to eq(tags_response)
    end
  end

  describe "write operations integration" do
    describe "item operations" do
      it "#create_item wraps single item in array" do
        item_data = { itemType: "book", title: "Test" }
        expect(client).to receive(:post).with("/users/123/items", data: [item_data], version: 150, write_token: nil)
        user_library.create_item(item_data, version: 150)
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

      it "#update_collection calls patch with correct path" do
        collection_data = { name: "Updated Name" }
        expect(client).to receive(:patch).with("/users/123/collections/XYZ789", data: collection_data, version: 150)
        user_library.update_collection("XYZ789", collection_data, version: 150)
      end

      it "#delete_collection calls delete with collection key" do
        expect(client).to receive(:delete).with("/users/123/collections/XYZ789", version: 150)
        user_library.delete_collection("XYZ789", version: 150)
      end
    end
  end

  describe "private methods" do
    describe "#create_single" do
      it "wraps data in array and calls client post" do
        data = { name: "Test" }
        expect(client).to receive(:post).with("/users/123/items", data: [data], version: 100, write_token: "token")
        user_library.send(:create_single, "items", data, version: 100, write_token: "token")
      end
    end

    describe "#create_multiple" do
      it "passes array directly to client post" do
        data_array = [{ name: "Test1" }, { name: "Test2" }]
        expect(client).to receive(:post).with("/users/123/items", data: data_array, version: 100, write_token: "token")
        user_library.send(:create_multiple, "items", data_array, version: 100, write_token: "token")
      end
    end

    describe "#validate_type" do
      it "accepts valid user type" do
        result = user_library.send(:validate_type, :user)
        expect(result).to eq("user")
      end

      it "accepts valid group type" do
        result = user_library.send(:validate_type, :group)
        expect(result).to eq("group")
      end

      it "raises error for invalid type" do
        expect do
          user_library.send(:validate_type, :invalid)
        end.to raise_error(ArgumentError, /Invalid library type: invalid/)
      end
    end
  end
end
