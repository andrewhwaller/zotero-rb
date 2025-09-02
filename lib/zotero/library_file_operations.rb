# frozen_string_literal: true

module Zotero
  # File upload operations for library items
  module LibraryFileOperations
    def create_attachment(attachment_data, version: nil, write_token: nil)
      create_single("items", attachment_data, version: version, write_token: write_token)
    end

    def get_file_info(item_key)
      @client.get("#{@base_path}/items/#{item_key}/file")
    end

    def upload_file(item_key, file_path)
      perform_file_upload(item_key, file_path, existing_file: false)
    end

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
      require "digest"

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
      if auth_response["url"]
        upload_params = build_upload_params(auth_response, file_path)
        @client.external_post(auth_response["url"], multipart_data: upload_params)
      end

      if auth_response["uploadKey"]
        @client.register_upload(upload_path, upload_key: auth_response["uploadKey"])
      else
        true
      end
    end

    def build_upload_params(auth_response, file_path)
      file_data = File.open(file_path, "rb")

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
