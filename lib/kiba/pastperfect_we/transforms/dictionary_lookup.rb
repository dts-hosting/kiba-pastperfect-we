# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # @param fields [Symbol, Array<Symbol>] fields containing ids to be
      #   looked up in DictionaryItem table
      # @param merge_desc [nil, Boolean] whether to merge the description field
      #   value from DictionaryItem table along with the title field value
      # @param lookup [nil, Hash] only send this a Hash if you are writing a
      #   test of this transform!
      class DictionaryLookup
        def initialize(fields:, merge_desc: nil, lookup: nil)
          @fields = [fields].flatten
          @merge_desc = if merge_desc.nil?
            Ppwe.merge_dictionary_item_descriptions
          else
            merge_desc
          end
          @lookup = lookup || Ppwe.get_lookup(
            jobkey: :preprocess__dictionary_item, column: :id
          )
          @mergers = @fields.map do |field|
            [field, build_merge_transform(field)]
          end.to_h
        end

        def process(row)
          mergers.each do |field, merger|
            merger.process(row) if row.key?(field)
          end
          fields.each { |field| row.delete(field) }
          row
        end

        private

        attr_reader :fields, :merge_desc, :lookup, :mergers

        def build_merge_transform(field)
          fieldmap = build_fieldmap(field)
          Merge::MultiRowLookup.new(
            lookup: lookup,
            keycolumn: field,
            fieldmap: fieldmap
          )
        end

        def build_fieldmap(field)
          base = {field_base_name(field) => :title}
          return base unless merge_desc

          base.merge({field_desc_name(field) => :description})
        end

        def field_base_name(field) = field.to_s.delete_suffix("id").to_sym

        def field_desc_name(field) = :"#{field_base_name(field)}_desc"
      end
    end
  end
end
