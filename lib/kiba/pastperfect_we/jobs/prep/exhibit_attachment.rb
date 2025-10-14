# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ExhibitAttachment
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
                source: :exhibit__target_system_lookup,
                join_column: :exhibitid,
                delete_join_column: false
            end
          end
        end
      end
    end
  end
end
