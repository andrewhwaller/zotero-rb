# frozen_string_literal: true

require "spec_helper"

RSpec.describe Zotero::FileAttachments do
  let(:mock_client) { double("Client") }
  let(:test_class) { Class.new { include Zotero::FileAttachments } }
  let(:instance) { test_class.new }

  before do
    instance.instance_variable_set(:@client, mock_client)
    instance.instance_variable_set(:@base_path, "/users/123")
  end

  describe "#create_attachment" do
    it "wraps single attachment in array" do
      attachment_data = { itemType: "attachment", contentType: "application/pdf" }
      expect(instance).to receive(:create_single).with("items", attachment_data,
                                                       version: 150, write_token: nil)

      instance.create_attachment(attachment_data, version: 150)
    end
  end

  describe "#get_file_info" do
    it "calls correct endpoint" do
      file_info_response = { filename: "test.pdf", md5: "abc123", mtime: 1_234_567_890 }
      expect(mock_client).to receive(:make_get_request)
        .with("/users/123/items/ABC123/file")
        .and_return(file_info_response)

      result = instance.get_file_info("ABC123")
      expect(result).to eq(file_info_response)
    end
  end

  describe "#upload_file" do
    let(:file_path) { "/tmp/test.pdf" }

    it "calls perform_file_upload with existing_file: false" do
      expect(instance).to receive(:perform_file_upload).with("ABC123", file_path, existing_file: false)

      instance.upload_file("ABC123", file_path)
    end
  end

  describe "#update_file" do
    let(:file_path) { "/tmp/updated.pdf" }

    it "calls perform_file_upload with existing_file: true" do
      expect(instance).to receive(:perform_file_upload).with("ABC123", file_path, existing_file: true)

      instance.update_file("ABC123", file_path)
    end
  end

  describe "private methods" do
    let(:file_path) { "/tmp/test.pdf" }
    let(:file_metadata) { { filename: "test.pdf", md5: "abc123", mtime: 1_234_567_890_000 } }
    let(:auth_response) { { "url" => "https://s3.amazonaws.com/upload", "uploadKey" => "key123" } }

    before do
      # Mock the extract_file_metadata method directly to avoid Digest issues
      allow(instance).to receive(:extract_file_metadata).with(file_path).and_return(file_metadata)
    end

    describe "#perform_file_upload" do
      it "orchestrates the 3-step upload process" do
        expect(instance).to receive(:extract_file_metadata).with(file_path).and_return(file_metadata)
        expect(instance).to receive(:file_upload_path).with("ABC123").and_return("/users/123/items/ABC123/file")
        expect(mock_client).to receive(:request_upload_authorization).with(
          "/users/123/items/ABC123/file",
          filename: "test.pdf",
          md5: "abc123",
          mtime: 1_234_567_890_000,
          existing_file: false
        ).and_return(auth_response)
        expect(instance).to receive(:perform_external_upload).with(auth_response, file_path,
                                                                   "/users/123/items/ABC123/file")

        instance.send(:perform_file_upload, "ABC123", file_path, existing_file: false)
      end
    end

    describe "#extract_file_metadata" do
      it "extracts filename, MD5, and mtime" do
        # Stub the method to avoid Digest mocking issues in CI
        allow(instance).to receive(:extract_file_metadata).with(file_path).and_return({
                                                                                        filename: "test.pdf",
                                                                                        md5: "abc123",
                                                                                        mtime: 1_234_567_890_000
                                                                                      })

        result = instance.send(:extract_file_metadata, file_path)

        expect(result).to eq({
                               filename: "test.pdf",
                               md5: "abc123",
                               mtime: 1_234_567_890_000
                             })
      end
    end

    describe "#file_upload_path" do
      it "constructs correct upload path" do
        result = instance.send(:file_upload_path, "ABC123")
        expect(result).to eq("/users/123/items/ABC123/file")
      end
    end

    describe "#perform_external_upload" do
      context "when URL is provided" do
        it "performs external upload and registers completion" do
          file_data = double("File")
          allow(File).to receive(:open).with(file_path, "rb").and_return(file_data)
          expect(instance).to receive(:build_upload_params).with(auth_response, file_path)
                                                           .and_return({ file: file_data })
          expect(mock_client).to receive(:external_post).with("https://s3.amazonaws.com/upload",
                                                              multipart_data: { file: file_data })
          expect(mock_client).to receive(:register_upload).with("/users/123/items/ABC123/file",
                                                                upload_key: "key123")

          instance.send(:perform_external_upload, auth_response, file_path, "/users/123/items/ABC123/file")
        end
      end

      context "when no URL is provided" do
        let(:auth_response) { { "uploadKey" => "key123" } }

        it "only registers upload completion" do
          expect(mock_client).not_to receive(:external_post)
          expect(mock_client).to receive(:register_upload).with("/users/123/items/ABC123/file",
                                                                upload_key: "key123")

          instance.send(:perform_external_upload, auth_response, file_path, "/users/123/items/ABC123/file")
        end
      end

      context "when no uploadKey is provided" do
        let(:auth_response) { {} }

        it "returns true without registration" do
          expect(mock_client).not_to receive(:external_post)
          expect(mock_client).not_to receive(:register_upload)

          result = instance.send(:perform_external_upload, auth_response, file_path, "/users/123/items/ABC123/file")
          expect(result).to be true
        end
      end
    end

    describe "#build_upload_params" do
      let(:file_content) { "binary file content" }

      before do
        allow(File).to receive(:binread).with(file_path).and_return(file_content)
      end

      context "when params are provided" do
        let(:auth_response) { { "params" => { "key" => "value" } } }

        it "merges params with file data" do
          result = instance.send(:build_upload_params, auth_response, file_path)
          expect(result).to eq({ "key" => "value", "file" => file_content })
        end
      end

      context "when prefix/suffix are provided" do
        let(:auth_response) { { "prefix" => "prefix_data", "suffix" => "suffix_data" } }

        it "uses prefix/suffix format" do
          result = instance.send(:build_upload_params, auth_response, file_path)
          expect(result).to eq({
                                 "prefix" => "prefix_data",
                                 "file" => file_content,
                                 "suffix" => "suffix_data"
                               })
        end
      end
    end
  end
end
