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
                lookup: :target_system_lookup__accession
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            acc_hdrs = %i[accessionid accessiontype accessionnumber]
            acc_hdrs << Ppwe::Splitting.item_type_field
            acc_hdrs << Ppwe.review_target_field
            acc_hdrs << :activity
            acc_hdrs
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__accession,
                keycolumn: :accessionid,
                fieldmap: {
                  :accessionnumber => :number,
                  :accessiontype => :accessiontype,
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
