# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Term
        module Usage
          module_function

          def job(dest:, tablename:)
            # Using orig__user as fake source for now because we don't have time
            #   for me to implement `SourcelessCsvOutputJob` in kiba-extend at
            #   the moment. User table is chosen because it should be present in
            #   any Ppwe instance AND be fairly small
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :orig__user,
                destination: dest
              },
              transformer: xforms(tablename)
            )
          end

          def xforms(tablename)
            Kiba.job_segment do
              transform Ppwe::Transforms::TermUseExtractor, table: tablename
            end
          end
        end
      end
    end
  end
end
