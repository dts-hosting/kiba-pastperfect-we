# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ArchiveIdentity
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[
                  prep__person
                  prep__site
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[eventid multilevelid]

              transform Merge::MultiRowLookup,
                lookup: prep__person,
                keycolumn: :creatorid,
                fieldmap: {creator_name: :fullname}

              transform Merge::MultiRowLookup,
                lookup: prep__site,
                keycolumn: :siteid,
                fieldmap: {sitename: :sitename}

              transform Delete::Fields,
                fields: :creatorid

              transform Ppwe::Transforms::CrSplitter,
                fields: :creatoraddedentry

              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_identity_people,
                join_column: :catalogitemid,
                delete_join_column: false,
                merged_field_prefix: "person"
            end
          end
        end
      end
    end
  end
end
