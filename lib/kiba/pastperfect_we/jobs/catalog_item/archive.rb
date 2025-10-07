# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module Archive
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :catalog_item__archive
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              drop_fields = %i[id position]
              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_structure,
                join_column: :catalogitemid,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_identity,
                join_column: :catalogitemid,
                delete_join_column: false,
                drop_fields: drop_fields

              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_allied_materials,
                join_column: :catalogitemid,
                delete_join_column: false

              content_fields = Ppwe.mergeable_headers_for(
                :prep__archive_structure
              ) + Ppwe.mergeable_headers_for(
                :prep__archive_identity, drop: drop_fields
              ) + Ppwe.mergeable_headers_for(
                :prep__archive_allied_materials
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
