# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Extracts basic info about references made to Term tables
      class TermUseExtractor
        def initialize
          @term_tables = Ppwe::Terms.table_config.keys
          @rows = []
        end

        def process(row) = nil

        def close
          term_tables.each { |tt| uses_for_table(tt) }
          rows.each { |row| yield row }
        end

        private

        # @return [Array<String>]
        attr_reader :term_tables

        attr_reader :rows

        # @param tt [String] table name
        def uses_for_table(tt)
          row = {termtable: tt}
          Ppwe::Terms.refs_to_terms_in(tt)
            .each do |reftable, refs|
              uses_from_table(reftable, refs, row)
            end
        end

        def uses_from_table(reftable, refs, row)
          return [] if Ppwe::Terms.skip_use_tables.include?(reftable)

          key = :"orig__#{Ppwe::Table.key(reftable)}"
          path = Ppwe.registry.resolve(key)&.path
          refdata = CSV.parse(
            File.read(path),
            headers: true,
            header_converters: %i[downcase symbol]
          )
          row[:referringtable] = reftable
          refidfield = Ppwe.lookup_column_for(reftable)
          refs.each { |ref| uses_from_column(refdata, refidfield, ref, row) }
        end

        def uses_from_column(refdata, refidfield, ref, row)
          puts "Extracting uses of #{row[:termtable]} from "\
            "#{ref.table}.#{ref.field}"
          row[:referringidfield] = refidfield
          row[:circular] = ref.circular
          refdata.each do |r|
            termid = r[ref.field]
            next if termid.blank?

            rows << row.merge({termid: termid, referringid: r[refidfield]})
          end
        end
      end
    end
  end
end
