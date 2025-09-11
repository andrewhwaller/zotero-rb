# frozen_string_literal: true

module Zotero
  # Item type discovery and template methods
  module ItemTypes
    # Get all available item types.
    #
    # @param locale [String] Optional locale for localized type names (e.g. 'en-US', 'fr-FR')
    # @return [Array<Hash>] Array of item type definitions
    def item_types(locale: nil)
      params = build_locale_params(locale)
      make_get_request("/itemTypes", params: params)
    end

    # Get all fields available for a specific item type.
    #
    # @param item_type [String] The item type name (e.g. 'book', 'journalArticle')
    # @param locale [String] Optional locale for localized field names
    # @return [Array<Hash>] Array of field definitions for the item type
    def item_type_fields(item_type, locale: nil)
      params = { itemType: item_type }
      params.merge!(build_locale_params(locale))
      make_get_request("/itemTypeFields", params: params)
    end

    # Get all creator types available for a specific item type.
    #
    # @param item_type [String] The item type name (e.g. 'book', 'journalArticle')
    # @return [Array<Hash>] Array of creator type definitions for the item type
    def item_type_creator_types(item_type)
      params = { itemType: item_type }
      make_get_request("/itemTypeCreatorTypes", params: params)
    end

    # Get a new item template for a specific item type.
    #
    # @param item_type [String] The item type name (e.g. 'book', 'journalArticle')
    # @return [Hash] Template object with empty fields for the item type
    def new_item_template(item_type)
      params = { itemType: item_type }
      make_get_request("/items/new", params: params)
    end

    private

    def build_locale_params(locale)
      locale ? { locale: locale } : {}
    end
  end
end
