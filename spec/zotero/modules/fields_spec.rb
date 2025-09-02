# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::Fields do
  let(:mock_client) { double("Client") }
  let(:test_class) { Class.new { include Zotero::Fields } }
  let(:instance) { test_class.new }

  before do
    instance.instance_variable_set(:@client, mock_client) if mock_client
    allow(instance).to receive(:get) { |*args| mock_client&.get(*args) }
  end

  describe "#item_fields" do
    it "returns item fields" do
      fields_response = [{ "field" => "title", "localized" => "Title" }]
      expect(instance).to receive(:get).with("/itemFields", params: {}).and_return(fields_response)

      result = instance.item_fields
      expect(result).to eq(fields_response)
    end

    it "returns item fields with locale" do
      fields_response = [{ "field" => "title", "localized" => "Titre" }]
      expect(instance).to receive(:get).with("/itemFields", params: { locale: "fr-FR" }).and_return(fields_response)

      result = instance.item_fields(locale: "fr-FR")
      expect(result).to eq(fields_response)
    end
  end

  describe "#creator_fields" do
    it "returns creator fields" do
      creator_fields_response = [{ "field" => "firstName", "localized" => "First Name" }]
      expect(instance).to receive(:get).with("/creatorFields", params: {}).and_return(creator_fields_response)

      result = instance.creator_fields
      expect(result).to eq(creator_fields_response)
    end

    it "returns creator fields with locale" do
      creator_fields_response = [{ "field" => "firstName", "localized" => "Prénom" }]
      expect(instance).to receive(:get).with("/creatorFields",
                                             params: { locale: "fr-FR" }).and_return(creator_fields_response)

      result = instance.creator_fields(locale: "fr-FR")
      expect(result).to eq(creator_fields_response)
    end
  end

  describe "private methods" do
    describe "#build_locale_params" do
      it "returns empty hash for nil locale" do
        result = instance.send(:build_locale_params, nil)
        expect(result).to eq({})
      end

      it "returns locale hash for valid locale" do
        result = instance.send(:build_locale_params, "fr-FR")
        expect(result).to eq({ locale: "fr-FR" })
      end
    end
  end
end
