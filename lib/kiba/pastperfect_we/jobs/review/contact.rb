# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Contact
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__contact,
                destination: :review__contact,
                lookup: [
                  :prep__contact_urls,
                  {
                    jobkey: :preprocess__contact_attachments,
                    lookup_on: :contactid
                  },
                  {
                    jobkey: :preprocess__contact_image,
                    lookup_on: :contactid
                  }
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Contact"
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Contact",
                term_src: :spouse

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_biographical_info,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_address_and_phone_numbers,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id

              transform Count::MatchingRowsInLookup,
                lookup: prep__contact_attachments,
                keycolumn: :id,
                targetfield: :attachment_count

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_urls,
                join_column: :id,
                delete_join_column: false,
                drop_fields: %i[id url_useradded]

              transform Count::MatchingRowsInLookup,
                lookup: preprocess__contact_image,
                keycolumn: :id,
                targetfield: :numberofimages
            end
          end
        end
      end
    end
  end
end
