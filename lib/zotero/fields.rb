# frozen_string_literal: true

module Zotero
  # Field discovery methods for Zotero items and creators
  module Fields
    # Get all available item fields.
    #
    # @param locale [String] Optional locale for localized field names (e.g. 'en-US', 'fr-FR')
    # @return [Array<Hash>] Array of field definitions with field names and localized labels
    def item_fields(locale: nil)
      params = build_locale_params(locale)
      make_get_request("/itemFields", params: params)
    end

    # Get all available creator fields.
    #
    # @param locale [String] Optional locale for localized field names (e.g. 'en-US', 'fr-FR')
    # @return [Array<Hash>] Array of creator field definitions with field names and localized labels
    def creator_fields(locale: nil)
      params = build_locale_params(locale)
      make_get_request("/creatorFields", params: params)
    end

    private

    def build_locale_params(locale)
      locale ? { locale: locale } : {}
    end
  end
end
