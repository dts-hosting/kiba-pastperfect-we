# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Person
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__person,
                destination: :person__combined
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__person_biographical_information,
                join_column: :id,
                drop_fields: %i[maritalstatus],
                opts: {null_placeholder: "FOO",
                       constantmap: {biomerged: "y"}}
            end
          end
        end
      end
    end
  end
end
