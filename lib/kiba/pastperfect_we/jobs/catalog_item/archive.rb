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

              # # I thought we discussed yesterday that the nature of
              # #   ArchiveContainerLocation made it unsuitable for
              # #   merge into this table, and that it would be a
              # #   separate catalog_item__archive_container_list
              # #   table? If that is still the case, I would delete
              # #   all the commented out code still in this file. If
              # #   you changed your mind on that point, delete the
              # #   Count::MatchingRowsInLookup,
              # #   Delete::FieldValueMatchingRegexp, and
              # #   Rplace::EmptyValues transforms I added, and
              # #   uncomment the remaining commented stuff. THOUGH,
              # #   this is another where the actual lookup id is and
              # #   should remain :id, but we need to merge here on
              # #   :catalogitemid. So you will need to change
              # #   MergeTable to a Merge::MultiRowLookup (so keep the
              # #   lookup file definition above)

              # drop_fields = %i[catalogitemid id position]
              # transform Ppwe::Transforms::MergeTable,
              #   source: :prep__archive_container_location,
              #   join_column: :catalogitemid,
              #   delete_join_column: false,
              #   drop_fields: drop_fields

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

              # + Ppwe.mergeable_headers_for(
              #   :prep__archive_container_location, drop: drop_fields
              # )

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
