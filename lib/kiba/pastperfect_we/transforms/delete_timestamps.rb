# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # @param fields [nil, Symbol, Array<Symbol>] fields from which timestamps
      #   will be deleted. If nil, timestamps will be removed from fields whose
      #   names end with "date"
      class DeleteTimestamps
        TIMESTAMP_PATTERN = / \d{2}:\d{2}:\d{2}(?:\.\d{3}| [AP]M)?$/

        def initialize(fields: nil)
          @fields_identified = fields ? true : false
          @fields = if fields
            [fields].flatten
          else
            []
          end
        end

        def process(row)
          identify_fields(row) unless fields_identified
          return row if fields.empty?

          fields.each { |field| delete_timestamp(row, field) }
          row
        end

        private

        attr_reader :fields_identified, :fields

        def identify_fields(row)
          @fields = row.keys
            .map(&:to_s)
            .select { |fld| fld.end_with?("date") }
            .map(&:to_sym)
          @fields_identified = true
        end

        def delete_timestamp(row, field)
          val = row[field]
          return row if val.blank?
          return row unless has_timestamp?(val)

          row[field] = val.sub(TIMESTAMP_PATTERN, "")
        end

        def has_timestamp?(val)
          val.match?(TIMESTAMP_PATTERN)
        end
      end
    end
  end
end
