# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Person
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__person,
                destination: :review__person,
                lookup: %i[
                  prep__person_url
                  prep__person_attachment
                ]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Person"
              transform Delete::Fields,
                fields: %i[createddate createdbyuserid]

              transform Ppwe::Transforms::MergeTable,
                source: :prep__person_biographical_information,
                join_column: :id,
                delete_join_column: false

              transform Count::MatchingRowsInLookup,
                lookup: prep__person_attachment,
                keycolumn: :id,
                targetfield: :attachment_count

              transform Merge::MultiRowLookup,
                lookup: prep__person_url,
                keycolumn: :id,
                fieldmap: {
                  url: :url_name,
                  url_display: :url_displayname
                }
            end
          end
        end
      end
    end
  end
end
