# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module Map
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :catalog_item__map,
                lookup: :prep__catalog_item_map_medium
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_map,
                join_column: :catalogitemid,
                delete_join_column: false
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_map_medium,
                keycolumn: :catalogitemid,
                fieldmap: {medium: :medium},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)

              content_fields = Ppwe.mergeable_headers_for(
                :prep__catalog_item_map
              ) + [:medium]
              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: content_fields
            end
          end
        end
      end
    end
  end
end
