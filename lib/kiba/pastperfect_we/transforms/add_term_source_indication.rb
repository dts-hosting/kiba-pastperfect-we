# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Appends term source indication to term-like value when in review
      #   mode
      class AddTermSourceIndication
        # @param table [String] name of table we're updating
        # @param term_src [nil, Symbol] field containing term value that will be
        #   merged into other table(s) as "term-like value"; Looks up from
        #   Ppwe::Terms.table_config if not provided
        # @param prefix [String] for the source indication segment
        def initialize(table:, term_src: nil,
          prefix: Ppwe::Terms.term_source_prefix)
          @table = table
          @term_src = term_src || Ppwe::Terms.table_config[table]
          @prefix = prefix
          @mode = Ppwe.mode
          @id_field = Ppwe.lookup_column_for(table)
        end

        def process(row)
          return row unless mode == :review

          val = row[term_src]
          term = val.blank? ? "{no value}" : val
          row[term_src] = "#{term}#{prefix}#{table}.#{row[id_field]}"
          row
        end

        private

        attr_reader :table, :term_src, :prefix, :mode, :id_field
      end
    end
  end
end
