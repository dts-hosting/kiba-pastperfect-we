# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module AppraisalReport
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__appraisal_report,
                destination: :review__appraisal_report,
                lookup: [
                  {
                    jobkey: :target_system_lookup__appraisal_report,
                    lookup_on: :id
                  }
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__appraisal_report,
                keycolumn: :id,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field,
                  Ppwe.review_target_field => Ppwe.review_target_field,
                  :itemid => :itemid
                }
            end
          end
        end
      end
    end
  end
end
