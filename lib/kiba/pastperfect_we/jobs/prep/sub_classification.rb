# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module SubClassification
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
                source: :prep__classification,
                join_column: :classificationid,
                drop_fields: :id,
                merged_field_prefix: "classification"
            end
          end
        end
      end
    end
  end
end
