# frozen_string_literal: true

require "digest"

module Zotero
  # File attachment operations for library items
  module FileAttachments
    # Create a new attachment item in the library.
    #
    # @param attachment_data [Hash] The attachment data including itemType, contentType, etc.
    # @param version [Integer] Optional version for conditional requests
    # @param write_token [String] Optional write token for batch operations
    # @return [Hash] The API response with created attachment
    def create_attachment(attachment_data, version: nil, write_token: nil)
      create_single("items", attachment_data, version: version, write_token: write_token)
    end

    # Get file information for an attachment item.
    #
    # @param item_key [String] The attachment item key
    # @return [Hash] File information including filename, md5, mtime
    def get_file_info(item_key)
      @client.make_get_request("#{@base_path}/items/#{item_key}/file")
    end

    # Upload a file to an attachment item.
    #
    # @param item_key [String] The attachment item key
    # @param file_path [String] Local path to the file to upload
    # @return [Boolean] Success status
    def upload_file(item_key, file_path)
      perform_file_upload(item_key, file_path, existing_file: false)
    end

    # Update the file content of an existing attachment.
    #
    # @param item_key [String] The attachment item key
    # @param file_path [String] Local path to the new file
    # @return [Boolean] Success status
    def update_file(item_key, file_path)
      perform_file_upload(item_key, file_path, existing_file: true)
    end

    private

    def perform_file_upload(item_key, file_path, existing_file:)
      file_metadata = extract_file_metadata(file_path)
      upload_path = file_upload_path(item_key)

      # Step 1: Request upload authorization
      auth_response = @client.request_upload_authorization(
        upload_path,
        **file_metadata,
        existing_file: existing_file
      )

      perform_external_upload(auth_response, file_path, upload_path)
    end

    def extract_file_metadata(file_path)
      {
        filename: File.basename(file_path),
        md5: Digest::MD5.file(file_path).hexdigest,
        mtime: File.mtime(file_path).to_i * 1000 # Convert to milliseconds
      }
    end

    def file_upload_path(item_key)
      "#{@base_path}/items/#{item_key}/file"
    end

    def perform_external_upload(auth_response, file_path, upload_path)
      upload_to_storage(auth_response, file_path) if auth_response["url"]
      register_upload_completion(auth_response, upload_path)
    end

    def upload_to_storage(auth_response, file_path)
      @client.external_post(auth_response["url"], multipart_data: build_upload_params(auth_response, file_path))
    end

    def register_upload_completion(auth_response, upload_path)
      return true unless auth_response["uploadKey"]

      @client.register_upload(upload_path, upload_key: auth_response["uploadKey"])
    end

    def build_upload_params(auth_response, file_path)
      file_data = File.binread(file_path)

      if auth_response["params"]
        auth_response["params"].merge("file" => file_data)
      else
        {
          "prefix" => auth_response["prefix"],
          "file" => file_data,
          "suffix" => auth_response["suffix"]
        }
      end
    end
  end
end
