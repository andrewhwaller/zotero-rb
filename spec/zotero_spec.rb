# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero do
  it "has a version number" do
    expect(Zotero::VERSION).not_to be_nil
  end

  describe ".new" do
    it "creates a new client instance with API key" do
      client = described_class.new(api_key: "test_key")
      expect(client).to be_a(Zotero::Client)
    end

    it "requires an API key" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end
end
