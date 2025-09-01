# frozen_string_literal: true

module Zotero
  # Field discovery methods
  module Fields
    def item_fields(locale: nil)
      get("/itemFields", params: build_locale_params(locale))
    end

    def creator_fields(locale: nil)
      get("/creatorFields", params: build_locale_params(locale))
    end

    private

    def build_locale_params(locale)
      locale ? { locale: locale } : {}
    end
  end
end
