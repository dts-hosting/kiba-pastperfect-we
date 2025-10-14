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
                destination: :catalog_item__archive,
                lookup: {
                  jobkey: :prep__archive_container_location,
                  lookup_on: :catalogitemid
                }
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_structure,
                join_column: :catalogitemid,
                delete_join_column: false
              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_identity,
                join_column: :catalogitemid,
                delete_join_column: false
              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_allied_materials,
                join_column: :catalogitemid,
                delete_join_column: false

              transform Count::MatchingRowsInLookup,
                lookup: prep__archive_container_location,
                keycolumn: :catalogitemid,
                targetfield: :numberofcontainerlists
              transform Delete::FieldValueMatchingRegexp,
                fields: :numberofcontainerlists,
                match: /^0$/

              content_fields = Ppwe.mergeable_headers_for(
                :prep__archive_allied_materials
              ) + Ppwe.mergeable_headers_for(
                :prep__archive_identity
              ) + Ppwe.mergeable_headers_for(
                :prep__archive_structure
              ) + [:containerlistcount]

              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: content_fields

              transform Replace::EmptyFieldValues,
                fields: :numberofcontainerlists,
                value: "0"
            end
          end
        end
      end
    end
  end
end
