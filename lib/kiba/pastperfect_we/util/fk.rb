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
          rows = foreign_keys.select do |row|
            row["Referenced table"] == table && row["Referenced field"] == field
          end
          to_ref(rows)
        end

        def to_ref(arr)
          arr.map do |row|
            parenttable = row["Parent table"]
            next unless Ppwe::Table.tablenames.include?(parenttable)

            table = row["Referenced table"]
            circ = table == parenttable
            sub = !circ &&
              parenttable.start_with?(table) &&
              sub_id?(row)
            Reference.new(row["Parent table"], row["Parent field"], circ, sub)
          end.compact
        end

        def sub_id?(row)
          return true if row["Parent column_id"].to_i == 1

          pf = row["Parent field"].downcase.to_s
          tf = "#{row["Referenced table"]}#{row["Referenced field"]}".downcase
          pf == tf
        end

        # @return [nil, Symbol] field containing catalogitemid reference id, if
        #   it exists in given table; otherwise nil
        def catalogitemid_field(table)
          direct_catalog_item_refs.find { |r| r.table == table }
        end

        def direct_catalog_item_refs
          @direct_catalog_item_refs ||=
            references_to("CatalogItem", :id) + to_ref(
              foreign_keys.select do |r|
                r["Referenced table"] == "CatalogItem" &&
                  r["Referenced field"] == :id
              end
            )
        end

        def indirect_catalog_item_refs
          @indirect_catalog_item_refs ||= to_ref(
            foreign_keys.select { |r| r["Referenced field"] == :catalogitemid }
          )
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
