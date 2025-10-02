# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ArchiveContainerLocation
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :prep__person
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__person,
                keycolumn: :creatorid,
                fieldmap: {creator_name: :fullname}

              transform Replace::FieldValueWithStaticMapping,
                source: :ispublicaccess,
                mapping: Ppwe.boolean_yes_no_mapping

              transform Delete::Fields,
                fields: :creatorid

              transform Ppwe::Transforms::MergeTable,
                source: :prep__archive_container_location_subjects,
                join_column: :id,
                delete_join_column: false
            end
          end
        end
      end
    end
  end
end
