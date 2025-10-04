# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Term
        module Uses
          module_function

          def job
            # Using orig__user as fake source for now because we don't have time
            #   for me to implement `SourcelessCsvOutputJob` in kiba-extend at
            #   the moment. User table is chosen because it should be present in
            #   any Ppwe instance AND be fairly small
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :orig__user,
                destination: :term__uses
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::TermUseExtractor
            end
          end
        end
      end
    end
  end
end
