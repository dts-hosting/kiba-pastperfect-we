# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Location
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__location,
                destination: :review__location
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Location"
            end
          end
        end
      end
    end
  end
end
