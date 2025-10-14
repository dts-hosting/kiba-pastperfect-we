# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module OutgoingLoanActivities
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__loan_activities,
                destination: :review__outgoing_loan_activities,
                lookup: :loan__target_system_lookup
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            acc_hdrs = %i[loanid loannumberandrecipient]
            acc_hdrs << Ppwe::Splitting.item_type_field
            acc_hdrs << Ppwe.review_target_field
            acc_hdrs << :activity
            acc_hdrs
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: loan__target_system_lookup,
                keycolumn: :loanid,
                fieldmap: {
                  :loannumberandrecipient => :loannumberandrecipient,
                  Ppwe.review_target_field => Ppwe.review_target_field,
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                }
            end
          end
        end
      end
    end
  end
end
