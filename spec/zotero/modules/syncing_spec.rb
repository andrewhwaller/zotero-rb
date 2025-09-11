# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::Syncing do
  let(:mock_client) { double("Client") }
  let(:test_class) { Class.new { include Zotero::Syncing } }
  let(:instance) { test_class.new }

  before do
    instance.instance_variable_set(:@client, mock_client)
    instance.instance_variable_set(:@base_path, "/users/123")
  end

  describe "#verify_api_key" do
    context "when used in Library context" do
      it "calls client get method" do
        api_response = { "userID" => 12_345, "username" => "testuser" }
        expect(mock_client).to receive(:make_get_request).with("/keys/current").and_return(api_response)

        result = instance.verify_api_key
        expect(result).to eq(api_response)
      end
    end

    context "when used in Client context" do
      before do
        instance.instance_variable_set(:@client, nil)
        allow(instance).to receive(:make_get_request)
      end

      it "calls own get method" do
        api_response = { "userID" => 12_345, "username" => "testuser" }
        expect(instance).to receive(:make_get_request).with("/keys/current").and_return(api_response)

        result = instance.verify_api_key
        expect(result).to eq(api_response)
      end
    end
  end

  describe "#user_groups" do
    context "when used in Library context" do
      it "returns user groups with default format" do
        groups_response = { "12345" => 42, "67890" => 15 }
        expect(mock_client).to receive(:make_get_request)
          .with("/users/789/groups", params: { format: "versions" })
          .and_return(groups_response)

        result = instance.user_groups(789)
        expect(result).to eq(groups_response)
      end

      it "returns user groups with custom format" do
        groups_response = [{ "id" => 12_345, "name" => "Test Group" }]
        expect(mock_client).to receive(:make_get_request).with("/users/789/groups",
                                                               params: { format: "json" }).and_return(groups_response)

        result = instance.user_groups(789, format: "json")
        expect(result).to eq(groups_response)
      end
    end

    context "when used in Client context" do
      before do
        instance.instance_variable_set(:@client, nil)
        allow(instance).to receive(:make_get_request)
      end

      it "calls own get method" do
        groups_response = { "12345" => 42 }
        expect(instance).to receive(:make_get_request).with("/users/789/groups",
                                                            params: { format: "versions" }).and_return(groups_response)

        result = instance.user_groups(789)
        expect(result).to eq(groups_response)
      end
    end
  end

  describe "#deleted_items" do
    it "returns deleted items without since parameter" do
      deleted_response = { "collections" => [], "items" => %w[ABC123 DEF456] }
      expect(mock_client).to receive(:make_get_request).with("/users/123/deleted",
                                                             params: {}).and_return(deleted_response)

      result = instance.deleted_items
      expect(result).to eq(deleted_response)
    end

    it "returns deleted items since version" do
      deleted_response = { "collections" => ["COL123"], "items" => ["ABC123"] }
      expect(mock_client).to receive(:make_get_request).with("/users/123/deleted",
                                                             params: { since: 42 }).and_return(deleted_response)

      result = instance.deleted_items(since: 42)
      expect(result).to eq(deleted_response)
    end

    it "works with different base paths" do
      instance.instance_variable_set(:@base_path, "/groups/456")
      deleted_response = { "collections" => [], "items" => ["XYZ789"] }
      expect(mock_client).to receive(:make_get_request).with("/groups/456/deleted",
                                                             params: { since: 100 }).and_return(deleted_response)

      result = instance.deleted_items(since: 100)
      expect(result).to eq(deleted_response)
    end
  end
end
