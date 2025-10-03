# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Util
      # Utility code module functionality related to foreign keys CSV
      module Fk
        module_function

        # Value object representing a table/field that refers to another
        #   table/field
        # @!attribute [r] table
        #   @return [String]
        # @!attribute [r] field
        #   @return [Symbol]
        # @!attribute [r] circular
        #   @return [Boolean] true if Parent table is the same as Referenced
        #      table
        # @!attribute [r] sub
        #   @return [Boolean] true if Parent table is a sub-table of Referenced
        #      table. These do not indicate a usage of a term, but linkage of a
        #      separate term details table to the main term table.
        Reference = Struct.new("Reference", :table, :field, :circular, :sub)

        # @param table [String]
        # @param field [Symbol]
        # @return [Reference]
        def references_to(table, field)
          foreign_keys.map do |row|
            tables = Ppwe::Table.tablenames
            parenttable = row["Parent table"]

            next unless row["Referenced table"] == table &&
              row["Referenced field"] == field &&
              tables.include?(parenttable)

            circ = table == parenttable
            sub = !circ &&
              parenttable.start_with?(table) &&
              row["Parent column_id"].to_i == 1
            Reference.new(row["Parent table"], row["Parent field"], circ, sub)
          end.compact
        end

        # @return [Array<CSV::Row>]
        def foreign_keys = @foreign_keys || get_foreign_keys

        def get_foreign_keys = CSV.read(Ppwe.foreign_keys_path, headers: true)
          .map do |row|
            ["Parent field", "Referenced field"].each do |f|
              row[f] = row[f].downcase.to_sym
            end
            row
          end
      end
    end
  end
end
