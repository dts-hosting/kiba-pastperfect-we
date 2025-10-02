# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module AccessionActivities
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__accession_activities,
                destination: :review__accession_activities,
                lookup: :accession__target_system_lookup
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            acc_hdrs = %i[accessionid accessiontype accessionnumber]
            acc_hdrs << Ppwe.review_target_field if Ppwe.mode == :review
            acc_hdrs << :activity
            acc_hdrs
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: accession__target_system_lookup,
                keycolumn: :accessionid,
                fieldmap: {
                  :accessionnumber => :number,
                  :accessiontype => :accessiontype,
                  Ppwe.review_target_field => Ppwe.review_target_field
                }
            end
          end
        end
      end
    end
  end
end
