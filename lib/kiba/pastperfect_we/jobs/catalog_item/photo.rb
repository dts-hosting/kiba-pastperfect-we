# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module Photo
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :catalog_item__photo,
                lookup: :prep__catalog_item_photo_medium
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              drop_fields = %i[id]
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_photo,
                join_column: :catalogitemid,
                delete_join_column: false,
                drop_fields: drop_fields
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_photo_medium,
                keycolumn: :catalogitemid,
                fieldmap: {medium: :medium},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)

              content_fields = Ppwe.mergeable_headers_for(
                :prep__catalog_item_photo
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
