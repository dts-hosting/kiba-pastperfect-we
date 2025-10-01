# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module OutgoingLoan
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__loan,
                destination: :review__outgoing_loan
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_insurance_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_shipping_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_contact_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_activities,
                join_column: :id,
                delete_join_column: false,
                merged_field_prefix: "activity"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_attachment,
                join_column: :id,
                delete_join_column: false,
                merged_field_prefix: "attachment"
            end
          end
        end
      end
    end
  end
end
