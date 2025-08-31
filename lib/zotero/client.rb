# frozen_string_literal: true

module Zotero
  class Client
    def initialize(api_key: nil, **options)
      @api_key = api_key || Zotero.configuration.api_key
      @options = options
    end

    private

    attr_reader :api_key, :options
  end
end
