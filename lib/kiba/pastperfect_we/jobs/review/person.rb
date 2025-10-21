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
                lookup: [
                  :prep__person_url,
                  {jobkey: :prep__person_attachment, lookup_on: :personid},
                  {jobkey: :prep__person_image, lookup_on: :personid}
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
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

              transform Merge::MultiRowLookup,
                lookup: prep__person_url,
                keycolumn: :id,
                fieldmap: Ppwe::Url.fieldmap

              transform Count::MatchingRowsInLookup,
                lookup: prep__person_attachment,
                keycolumn: :id,
                targetfield: :numberofattachments

              transform Count::MatchingRowsInLookup,
                lookup: prep__person_image,
                keycolumn: :id,
                targetfield: :numberofimages
            end
          end
        end
      end
    end
  end
end
