# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module CatalogItem
      module_function

      extend Dry::Configurable

      # @return [Array<Symbol>] fields from :prep__catalog_item to keep as
      #   scaffold for merging/splitting data into deliverable files
      setting :base_fields,
        reader: true,
        default: %i[catalogitemid itemtype itemid],
        constructor: ->(default) do
          return default if Ppwe.mode == :migration

          default + [Ppwe.review_target_field]
        end

      # @return [Array<Symbol>] fields from :prep__catalog_item included in
      #   :catalog_item__basic_info; list in order you wish fields to appear
      #   in output file
      setting :basic_info_fields,
        reader: true,
        default: %i[objectname title description
          creationdate yearrangefrom yearrangeto
          dimensions itemcount collection accessionnumber
          status homelocation templocation
          deaccessioned isremoved]

      # @return [Array<Symbol>] fields from :prep__catalog_item
      #   included in :catalog_item__deaccession_and_removal; list in
      #   order you wish fields to appear in output file
      setting :deaccession_and_removal_fields,
        reader: true,
        default: %i[deaccessioned deaccessiondate deaccessionreasonnotes
          deaccessionauthorizedbyuser isremoved removaldate
          disposaldate disposalmethod]

      # @return [Array<Symbol>] fields from :prep__catalog_item
      #   included in :catalog_item__id_name_class; list in
      #   order you wish fields to appear in output file
      setting :id_name_class_fields,
        reader: true,
        default: %i[alternativeitemid oldnumber
          objectname objectname2 objectname3
          othername othernames
          accessionid]
    end
  end
end
