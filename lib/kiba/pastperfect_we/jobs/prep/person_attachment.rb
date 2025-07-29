# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module PersonAttachment
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
                source: :prep__attachment,
                join_column: :attachmentid
              transform Delete::EmptyFields
            end
          end
        end
      end
    end
  end
end
