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

  # HTTP verb methods have been removed - functionality is now tested through
  # the modules that use http_request directly (Library, Fields, ItemTypes, etc.)

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
