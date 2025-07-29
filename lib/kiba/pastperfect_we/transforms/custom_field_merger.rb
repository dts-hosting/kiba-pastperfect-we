# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Merges values from prepped custom field tables (e.g.
      #   AccessionCustomField, CatalogItemCustomField) into prepped
      #   parent table (e.g. Accession, CatalogItem)
      class CustomFieldMerger
        # @param parent_table [String] name of parent table
        def initialize(parent_table:)
          @parent = parent_table
          lookup_key = :"prep__#{parent.underscore}_custom_field"
          @lookup = Ppwe.get_lookup(
            jobkey: lookup_key, column: Ppwe.lookup_on_for(lookup_key)
          )
          @mergers = compile_merge_fields.map { |field| merger_for(field) }
        end

        def process(row)
          mergers.each { |merger| merger.process(row) }
          row
        end

        private

        attr_reader :parent, :lookup, :mergers

        def compile_merge_fields
          lookup.values
            .flatten
            .map { |row| row[:customfield_name] }
            .uniq
        end

        def merger_for(field)
          target_base = field.downcase
            .tr(" ", "_")
          Merge::MultiRowLookup.new(
            lookup: lookup,
            keycolumn: :id,
            fieldmap: {
              "#{target_base}": :customfield_value,
              "#{target_base}_desc": :customfield_valuedesc
            },
            conditions: ->(_r, rows) do
              rows.select do |row|
                row[:customfield_name] == field
              end
            end
          )
        end
      end
    end
  end
end
