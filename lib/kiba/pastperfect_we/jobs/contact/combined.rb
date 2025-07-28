# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Contact
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__contact,
                destination: :contact__combined
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_attachments,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id,
                merged_field_prefix: "attachment"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__flag,
                join_column: :flagid,
                delete_join_column: false,
                opts: {null_placeholder: Ppwe.nullvalue},
                merged_field_prefix: "flag"
            end
          end
        end
      end
    end
  end
end
