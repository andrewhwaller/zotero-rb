# frozen_string_literal: true

module Zotero
  # Item type discovery and template methods
  module ItemTypes
    def item_types(locale: nil)
      get("/itemTypes", params: build_locale_params(locale))
    end

    def item_type_fields(item_type, locale: nil)
      params = { itemType: item_type }
      params.merge!(build_locale_params(locale))
      get("/itemTypeFields", params: params)
    end

    def item_type_creator_types(item_type)
      get("/itemTypeCreatorTypes", params: { itemType: item_type })
    end

    def new_item_template(item_type)
      get("/items/new", params: { itemType: item_type })
    end

    private

    def build_locale_params(locale)
      locale ? { locale: locale } : {}
    end
  end
end
