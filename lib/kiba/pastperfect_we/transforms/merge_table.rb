# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Merge the source table given in this transform into the source(s)
      #  specified in the job definition from where it is called
      # @note Use this transform when you need to merge most/all of the
      #   fields in the source table into the calling/target table. If you
      #   only need to merge one or a few fields into the calling/target
      #   table, it'll be less typing to use the kiba-extend
      #   Merge::MultiRowLookup transform directly.
      class MergeTable
        # @param source [Symbol] job key for merge source table
        # @param join_column [Symbol] field in calling/target table containing
        #   value to match against lookup_on column in source table
        # @param delete_join_column [Boolean] whether to delete the join column
        #   after joining
        # @param drop_fields [Array<Symbol>] fields NOT to merge from the source
        #   table. NOTE: known/registered ID fields and created/modified by/date
        #   fields are automatically excluded
        # @param merged_field_prefix [nil, String] added to each merged-in field
        # @param opts [nil, Hash] of additional kiba-extend
        #   Merge::MultiRowLookup parameters to pass through. The following
        #   parameters cannot be passed through: lookup, keycolumn, fieldmap
        def initialize(source:, join_column:, delete_join_column: true,
          drop_fields: [], merged_field_prefix: nil, opts: nil)
          @source = source
          @join_column = join_column
          @delete = delete_join_column
          @drop = drop_fields
          @prefix = merged_field_prefix
          @opts = opts
          @lookup = Ppwe.get_lookup(
            jobkey: source, column: Ppwe.lookup_on_for(source)
          )
          @merger = Merge::MultiRowLookup.new(**build_merge_transform_opts)
        end

        def process(row)
          merger.process(row)
          row.delete(join_column) if delete
          row
        end

        private

        attr_reader :source, :join_column, :delete, :drop, :prefix, :opts,
          :lookup, :merger

        def build_merge_transform_opts
          base = {
            lookup: lookup,
            keycolumn: join_column,
            fieldmap: build_merge_map
          }
          return base unless opts

          base.merge(clean_opts)
        end

        def build_merge_map
          result = Ppwe.mergeable_headers_for(
            source, drop: drop
          ).map { |field| [field, field] }
            .to_h
          return result unless prefix

          result.transform_keys { |key| :"#{prefix}_#{key}" }
        end

        def clean_opts
          forbidden = %i[lookup keycolumn fieldmap]
          return opts unless opts.keys.any? { |opt| forbidden.include?(opt) }

          forbidden.each { |opt| opts.delete(opt) }
          opts
        end
      end
    end
  end
end
