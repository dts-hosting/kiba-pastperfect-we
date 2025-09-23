# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module History
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :catalog_item__history
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              drop_fields = %i[id position]
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_history,
                join_column: :catalogitemid,
                delete_join_column: false,
                drop_fields: drop_fields
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_history_material,
                join_column: :catalogitemid,
                delete_join_column: false,
                drop_fields: drop_fields
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_history_origin,
                join_column: :catalogitemid,
                delete_join_column: false,
                drop_fields: drop_fields
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_history_place_found,
                join_column: :catalogitemid,
                delete_join_column: false,
                drop_fields: drop_fields

              content_fields = Ppwe.mergeable_headers_for(
                :prep__catalog_item_history
              ) + Ppwe.mergeable_headers_for(
                :prep__catalog_item_history_material, drop: drop_fields
              ) + Ppwe.mergeable_headers_for(
                :prep__catalog_item_history_origin, drop: drop_fields
              ) + Ppwe.mergeable_headers_for(
                :prep__catalog_item_history_place_found, drop: drop_fields
              )

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
