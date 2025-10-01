# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Adds Ppwe.review_target_field field containing the names of target
      #  systems or other disposition for the row
      class ReviewTargetFieldMerger
        include Kiba::Extend::Transforms::SingleWarnable

        def initialize
          @source = Ppwe::Splitting.item_type_field
          @target = Ppwe.review_target_field
          @mapping = Ppwe::Splitting.item_type_mapping
            .transform_values { |v| v.to_s.tr("_", " ") }
          @weaklings = Ppwe::Splitting.weak_targets
            .map { |v| v.to_s.tr("_", " ") }
          setup_single_warning
        end

        def process(row)
          unless row.key?(source)
            add_single_warning(":#{source} field does not exist to be used "\
                              "as source for ReviewTargetFieldMerger transform")
            return
          end

          row[target] = map_itemtypes(row[source])
          row
        end

        private

        attr_reader :source, :target, :mapping, :weaklings

        def map_itemtypes(types)
          return mapping[types] unless types

          grouped = types.split(Ppwe.delim)
            .map { |v| mapping[v] }
            .uniq
            .group_by { |v| weaklings.include?(v) }

          return grouped[false].sort.join(Ppwe.delim) if grouped.key?(false)

          grouped[true].sort.join(Ppwe.delim)
        end
      end
    end
  end
end
