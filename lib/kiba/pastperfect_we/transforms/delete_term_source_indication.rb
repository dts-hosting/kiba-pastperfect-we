# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Removes term source indication from term-like value when in review
      #   mode
      class DeleteTermSourceIndication
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
        end

        def process(row)
          return row unless mode == :review

          val = row[term_src]
          return row if val.blank?

          row[term_src] = val.sub(/#{prefix}.*$/, "")
          row
        end

        private

        attr_reader :table, :term_src, :prefix, :mode
      end
    end
  end
end
