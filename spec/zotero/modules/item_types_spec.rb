# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::ItemTypes do
  let(:mock_client) { double("Client") }
  let(:test_class) { Class.new { include Zotero::ItemTypes } }
  let(:instance) { test_class.new }

  before do
    instance.instance_variable_set(:@client, mock_client) if mock_client
    allow(instance).to receive(:make_get_request) { |*args| mock_client&.make_get_request(*args) }
  end

  describe "#item_types" do
    it "returns item types without locale" do
      item_types_response = [{ "itemType" => "book", "localized" => "Book" }]
      expect(instance).to receive(:make_get_request).with("/itemTypes", params: {}).and_return(item_types_response)

      result = instance.item_types
      expect(result).to eq(item_types_response)
    end

    it "returns item types with locale" do
      item_types_response = [{ "itemType" => "book", "localized" => "Livre" }]
      expect(instance).to receive(:make_get_request).with("/itemTypes",
                                                          params: { locale: "fr-FR" }).and_return(item_types_response)

      result = instance.item_types(locale: "fr-FR")
      expect(result).to eq(item_types_response)
    end
  end

  describe "#item_type_fields" do
    it "returns fields for item type" do
      type_fields_response = [{ "field" => "title", "localized" => "Title" }]
      expect(instance).to receive(:make_get_request).with("/itemTypeFields",
                                                          params: { itemType: "book" }).and_return(type_fields_response)

      result = instance.item_type_fields("book")
      expect(result).to eq(type_fields_response)
    end

    it "returns fields for item type with locale" do
      type_fields_response = [{ "field" => "title", "localized" => "Titre" }]
      expect(instance).to receive(:make_get_request).with("/itemTypeFields",
                                                          params: { itemType: "book",
                                                                    locale: "fr-FR" }).and_return(type_fields_response)

      result = instance.item_type_fields("book", locale: "fr-FR")
      expect(result).to eq(type_fields_response)
    end
  end

  describe "#item_type_creator_types" do
    it "returns creator types for item type" do
      creator_types_response = [{ "creatorType" => "author", "localized" => "Author" }]
      expect(instance).to receive(:make_get_request)
        .with("/itemTypeCreatorTypes", params: { itemType: "book" })
        .and_return(creator_types_response)

      result = instance.item_type_creator_types("book")
      expect(result).to eq(creator_types_response)
    end
  end

  describe "#new_item_template" do
    it "returns new item template" do
      template_response = { "itemType" => "book", "title" => "", "creators" => [] }
      expect(instance).to receive(:make_get_request).with("/items/new",
                                                          params: { itemType: "book" }).and_return(template_response)

      result = instance.new_item_template("book")
      expect(result).to eq(template_response)
    end
  end
end
