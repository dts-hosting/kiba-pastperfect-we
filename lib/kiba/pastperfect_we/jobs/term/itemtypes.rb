# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Term
        module Itemtypes
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :term__uses,
                destination: :term__itemtypes
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::TermUseItemTypeAssigner
            end
          end
        end
      end
    end
  end
end
