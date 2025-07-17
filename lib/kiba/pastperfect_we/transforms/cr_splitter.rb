# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Split carriage-return ("%CR%" in the exported data)-delimited values
      #   with specified delimiter instead
      class CrSplitter
        # @param fields [Symbol, Array<Symbol] field(s) to split
        # @param delim [String] multival delimiter to use instead of CR
        # @param collapse_multi_crs [Boolean] whether to treat two or more
        #   subsequent CRs as one
        def initialize(fields:, delim: Ppwe.delim, collapse_multi_crs: true)
          @fields = [fields].flatten
          @delim = delim
          @matcher = if collapse_multi_crs
            /(?:%CR%)+/
          else
            /%CR%/
          end
        end

        def process(row)
          fields.each { |field| split_field(field, row) }
          row
        end

        private

        attr_reader :fields, :delim, :matcher

        def split_field(field, row)
          val = row[field]
          return unless val&.match?(matcher)

          row[field] = val.gsub(matcher, delim)
        end
      end
    end
  end
end
