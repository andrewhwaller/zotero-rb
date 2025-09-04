# frozen_string_literal: true

module Zotero
  # File upload methods for handling attachment uploads
  module FileUpload
    def post_form(path, form_data:, if_match: nil, if_none_match: nil, params: {})
      headers = auth_headers.merge(default_headers)
      headers["Content-Type"] = "application/x-www-form-urlencoded"
      headers["If-Match"] = if_match if if_match
      headers["If-None-Match"] = if_none_match if if_none_match

      response = http_request(:post, path, headers: headers, body: form_data, params: params)
      handle_response(response)
    end

    def external_post(url, multipart_data:)
      response = http_request(:post, url, body: multipart_data, multipart: true, format: :plain)

      case response.code
      when 200..299
        response.body
      else
        raise Error, "External upload failed: HTTP #{response.code} - #{response.message}"
      end
    end

    def request_upload_authorization(path, filename:, md5: nil, mtime: nil, existing_file: false)
      form_data = { upload: filename, md5: md5, mtime: mtime }.compact

      if existing_file
        post_form(path, form_data: form_data, if_match: md5.to_s)
      else
        post_form(path, form_data: form_data, if_none_match: "*")
      end
    end

    def register_upload(path, upload_key:)
      post_form(path, form_data: { upload: upload_key })
    end
  end
end
