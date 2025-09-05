# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::Fulltext do
  let(:mock_client) { double("Client") }
  let(:test_class) { Class.new { include Zotero::Fulltext } }
  let(:instance) { test_class.new }

  before do
    instance.instance_variable_set(:@client, mock_client)
    instance.instance_variable_set(:@base_path, "/users/123")
  end

  describe "#fulltext_since" do
    it "calls correct endpoint with since parameter" do
      fulltext_response = { "ABC123" => 42, "DEF456" => 15 }
      expect(mock_client).to receive(:make_get_request).with("/users/123/fulltext",
                                                             params: { since: 100 }).and_return(fulltext_response)

      result = instance.fulltext_since(since: 100)
      expect(result).to eq(fulltext_response)
    end

    it "requires the since parameter" do
      expect { instance.fulltext_since }.to raise_error(ArgumentError)
    end
  end

  describe "#item_fulltext" do
    it "calls correct endpoint for specific item" do
      content_response = { "content" => "Sample text", "indexedChars" => 11, "totalChars" => 11 }
      expect(mock_client).to receive(:make_get_request)
        .with("/users/123/items/ABC123/fulltext")
        .and_return(content_response)

      result = instance.item_fulltext("ABC123")
      expect(result).to eq(content_response)
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
      expect(mock_client).to receive(:make_write_request).with(
        :put,
        "/users/123/items/ABC123/fulltext",
        data: content_data,
        options: { version: nil }
      ).and_return(true)

      result = instance.set_item_fulltext("ABC123", content_data)
      expect(result).to be true
    end

    it "accepts version parameter" do
      expect(mock_client).to receive(:make_write_request).with(
        :put,
        "/users/123/items/ABC123/fulltext",
        data: content_data,
        options: { version: 42 }
      ).and_return(true)

      result = instance.set_item_fulltext("ABC123", content_data, options: { version: 42 })
      expect(result).to be true
    end
  end
end
