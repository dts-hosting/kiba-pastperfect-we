# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Config module for settings and functionality related to the Url
    #   table and known child/auxiliary tables such as ContactUrls and
    #   CatalogItemUrl
    module Url
      extend MultiRectypeItemTypeMergable

      module_function

      extend Dry::Configurable

      setting :fieldmap,
        reader: true,
        default: {},
        constructor: ->(default) do
          %i[url url_dateadded url_ispublicaccess url_displayname
            url_addedby].map { |f| [f, f] }
            .to_h
        end

      setting :merge_config,
        reader: true,
        default: nil,
        constructor: ->(default) { get_merge_config(:url) }

      setting :lookup_file_config,
        reader: true,
        default: [],
        constructor: ->(default) { get_lookup_file_config(:url) }

      setting :itemtype_fields,
        reader: true,
        default: [],
        constructor: ->(default) { get_itemtype_fields }
    end
  end
end
