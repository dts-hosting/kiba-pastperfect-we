# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LoanAttachment
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :target_system_lookup__loan,
                join_column: :loanid,
                delete_join_column: false
            end
          end
        end
      end
    end
  end
end
