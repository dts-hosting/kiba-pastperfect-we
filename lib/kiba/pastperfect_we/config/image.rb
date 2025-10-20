# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Config module for settings and functionality related to the Image
    #   table and known child/auxiliary tables such as ExhibitImage and
    #   CatalogItemImage
    module Image
      extend MultiRectypeItemTypeMergable

      module_function

      extend Dry::Configurable

      setting :merge_config,
        reader: true,
        default: nil,
        constructor: ->(default) { get_merge_config(:image) }

      setting :lookup_file_config,
        reader: true,
        default: [],
        constructor: ->(default) { get_lookup_file_config(:image) }

      setting :itemtype_fields,
        reader: true,
        default: [],
        constructor: ->(default) { get_itemtype_fields }
    end
  end
end
