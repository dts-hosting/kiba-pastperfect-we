# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      class DictionaryLookup
        def initialize(fields:)
          @fields = fields
          @lookup = Ppwe.get_lookup(
            jobkey: :preprocess__dictionary_item, column: :id
          )
          @mergers = fields.map { |field| build_merge_transform(field) }
        end

        def process(row)
          mergers.each { |merger| merger.process(row) }
          fields.each { |field| row.delete(field) }
          row
        end

        private

        attr_reader :fields, :lookup, :mergers

        def build_merge_transform(field)
          Merge::MultiRowLookup.new(
            lookup: lookup,
            keycolumn: field,
            fieldmap: {
              field_base_name(field) => :title,
              field_desc_name(field) => :description
            }
          )
        end

        def field_base_name(field) = field.to_s.delete_suffix("id").to_sym

        def field_desc_name(field) = :"#{field_base_name(field)}_desc"
      end
    end
  end
end
