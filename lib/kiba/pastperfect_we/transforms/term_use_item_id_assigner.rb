# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Assigns associated catalogitemid(s) to each term use
      class TermUseItemIdAssigner
        def initialize
          @rows = []
          @target = :itemid
        end

        def process(row)
          rows << row.merge({target => nil})
          nil
        end

        def close
          rows.group_by { |r| r[:referringtable] }
            .each { |reftable, refrows| add_ids(reftable, refrows) }

          rows.each { |row| yield row }
        end

        private

        attr_reader :rows, :target

        def add_ids(reftable, refrows)
          if reftable == "CatalogItem"
            refrows.each { |r| r[target] = r[:referringid] }
          elsif refrows.first[:referringidfield] == "catalogitemid"
            refrows.each { |r| r[target] = r[:referringid] }
          else
            ciref = Ppwe::Util::Fk.catalogitemid_field(reftable)
            if ciref
              get_catalog_item_ids(ciref, refrows) && return
            end
          end
        end

        def get_catalog_item_ids(ref, refrows)
          key = :"orig__#{Ppwe::Table.key(ref.table)}"
          path = Ppwe.registry.resolve(key)&.path
          lookup_id = Ppwe.lookup_column_for(ref.table)
          lookup = Kiba::Extend::Utils::Lookup.csv_to_hash(
            file: path, keycolumn: lookup_id
          )
          populate_ids(refrows, lookup, ref)
        end

        def populate_ids(refrows, lookup, ref)
          refrows.each do |r|
            mergerow = lookup[r[:referringid]]&.first
            r[target] = mergerow[ref.field]
          end
        end
      end
    end
  end
end
