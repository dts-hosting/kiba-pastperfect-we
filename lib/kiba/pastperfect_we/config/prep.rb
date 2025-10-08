# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Prep
      module_function

      extend Dry::Configurable

      # Used to add initial headers to dynamically build registry entries
      #   for prep jobs
      # @return [Hash{String => Hash{:initial_headers => Array<Symbol>}}]
      setting :dest_special_opts,
        reader: true,
        default: {
          "CatalogItem" => {initial_headers: %i[id itemtype]},
          "CatalogItemUrl" => {initial_headers: %i[id catalogitemid url]},
          "IncomingLoanReturnedItems" => {
            initial_headers: %i[
              id accessionid loannumber catalogitemid
            ]
          },
          "LexiconItem" => {initial_headers: %i[
            id objectname objectnametype
          ]},
          "LocationHistoryItem" => {
            initial_headers: %i[
              id catalogitemid movetype
            ]
          }
        }

      # @param mod [Module] calling this method
      def get_xforms(mod)
        [
          mod.xforms,
          custom_field_merge_xforms(mod.to_s.split("::").last),
          final_xforms
        ].compact
      end

      def custom_field_merge_xforms(table)
        return nil unless Ppwe.tables_with_custom_fields.include?(table)

        Kiba.job_segment do
          transform Ppwe::Transforms::CustomFieldMerger,
            parent_table: table
        end
      end

      def final_xforms
        Kiba.job_segment do
          transform Delete::EmptyFields
        end
      end
    end
  end
end
