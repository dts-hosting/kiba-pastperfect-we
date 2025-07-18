# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module PersonUrl
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
                source: :prep__url,
                join_column: :urlid,
                merged_field_prefix: "url"
            end
          end
        end
      end
    end
  end
end
