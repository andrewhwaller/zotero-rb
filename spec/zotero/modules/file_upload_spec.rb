# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::FileUpload do
  let(:test_class) { Class.new { include Zotero::FileUpload } }
  let(:instance) { test_class.new }

  before do
    # Mock the http_request method that FileUpload now uses
    allow(instance).to receive(:http_request)

    # Mock the auth methods that FileUpload expects from Client
    allow(instance).to receive(:auth_headers).and_return({ "Zotero-API-Key" => "test_key" })
    allow(instance).to receive(:default_headers).and_return({ "Zotero-API-Version" => "3" })
    allow(instance).to receive(:handle_response, &:parsed_response)
  end

  describe "#post_form" do
    let(:form_data) { { upload: "test.pdf", md5: "abc123" } }

    it "makes form-encoded POST request with if_none_match" do
      expected_headers = {
        "Zotero-API-Key" => "test_key",
        "Zotero-API-Version" => "3",
        "Content-Type" => "application/x-www-form-urlencoded",
        "If-None-Match" => "*"
      }
      response = double("Response", code: 200, parsed_response: { "url" => "https://upload.zotero.org" })

      expect(instance).to receive(:http_request).with(
        :post,
        "/users/123/items/ABC123/file",
        headers: expected_headers,
        body: form_data,
        params: {}
      ).and_return(response)

      result = instance.post_form("/users/123/items/ABC123/file",
                                  form_data: form_data,
                                  if_none_match: "*")
      expect(result).to eq({ "url" => "https://upload.zotero.org" })
    end

    it "makes form-encoded POST request with if_match" do
      expected_headers = {
        "Zotero-API-Key" => "test_key",
        "Zotero-API-Version" => "3",
        "Content-Type" => "application/x-www-form-urlencoded",
        "If-Match" => "def456"
      }
      response = double("Response", code: 200, parsed_response: {})

      expect(instance).to receive(:http_request).with(
        :post,
        "/users/123/items/ABC123/file",
        headers: expected_headers,
        body: form_data,
        params: {}
      ).and_return(response)

      result = instance.post_form("/users/123/items/ABC123/file",
                                  form_data: form_data,
                                  if_match: "def456")
      expect(result).to eq({})
    end
  end

  describe "#external_post" do
    let(:multipart_data) { { file: "data", key: "value" } }

    it "makes multipart POST to external URL" do
      response = double("Response", code: 200, body: "Upload successful")

      expect(instance).to receive(:http_request).with(
        :post,
        "https://s3.amazonaws.com/upload",
        body: multipart_data,
        options: { multipart: true, format: :plain }
      ).and_return(response)

      result = instance.external_post("https://s3.amazonaws.com/upload", multipart_data: multipart_data)
      expect(result).to eq("Upload successful")
    end

    it "raises error on upload failure" do
      response = double("Response", code: 500, message: "Server Error")

      expect(instance).to receive(:http_request).and_return(response)

      expect do
        instance.external_post("https://s3.amazonaws.com/upload", multipart_data: multipart_data)
      end.to raise_error(Zotero::Error, /External upload failed: HTTP 500/)
    end
  end

  describe "#request_upload_authorization" do
    it "makes form request for new file upload" do
      expect(instance).to receive(:post_form).with(
        "/users/123/items/ABC123/file",
        form_data: { upload: "test.pdf", md5: "abc123", mtime: 1_234_567_890 },
        if_none_match: "*"
      ).and_return({ "url" => "https://upload.url" })

      result = instance.request_upload_authorization(
        "/users/123/items/ABC123/file",
        filename: "test.pdf",
        md5: "abc123",
        mtime: 1_234_567_890
      )
      expect(result).to eq({ "url" => "https://upload.url" })
    end

    it "makes form request for existing file update" do
      expect(instance).to receive(:post_form).with(
        "/users/123/items/ABC123/file",
        form_data: { upload: "test.pdf", md5: "new_hash" },
        if_match: "new_hash"
      ).and_return({})

      result = instance.request_upload_authorization(
        "/users/123/items/ABC123/file",
        filename: "test.pdf",
        md5: "new_hash",
        existing_file: true
      )
      expect(result).to eq({})
    end

    it "filters out nil values from form data" do
      expect(instance).to receive(:post_form).with(
        "/users/123/items/ABC123/file",
        form_data: { upload: "test.pdf" },
        if_none_match: "*"
      ).and_return({})

      instance.request_upload_authorization(
        "/users/123/items/ABC123/file",
        filename: "test.pdf",
        md5: nil,
        mtime: nil
      )
    end
  end

  describe "#register_upload" do
    it "registers upload completion with upload key" do
      expect(instance).to receive(:post_form).with(
        "/users/123/items/ABC123/file",
        form_data: { upload: "upload_key_123" }
      ).and_return(true)

      result = instance.register_upload("/users/123/items/ABC123/file", upload_key: "upload_key_123")
      expect(result).to be true
    end
  end
end
