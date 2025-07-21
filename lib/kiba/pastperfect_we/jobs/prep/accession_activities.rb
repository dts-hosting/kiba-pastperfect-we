# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module AccessionActivities
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__activity,
                join_column: :activityid,
                merged_field_prefix: "activity"
            end
          end
        end
      end
    end
  end
end
