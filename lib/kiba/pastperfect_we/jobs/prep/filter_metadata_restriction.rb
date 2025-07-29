# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module FilterMetadataRestriction
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
                source: :preprocess__filter_metadata,
                join_column: :metadataid
            end
          end
        end
      end
    end
  end
end
