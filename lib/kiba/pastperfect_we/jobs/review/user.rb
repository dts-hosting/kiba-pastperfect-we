# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module User
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__user,
                destination: :review__user
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "User"
            end
          end
        end
      end
    end
  end
end
