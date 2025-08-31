# frozen_string_literal: true

RSpec.describe Zotero do
  it "has a version number" do
    expect(Zotero::VERSION).not_to be_nil
  end

  describe ".new" do
    it "creates a new client instance" do
      client = described_class.new
      expect(client).to be_a(Zotero::Client)
    end
  end

  describe ".configure" do
    it "yields configuration object" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.configuration)
    end
  end

  describe ".configuration" do
    it "returns configuration instance" do
      expect(described_class.configuration).to be_a(Zotero::Configuration)
    end
  end
end
