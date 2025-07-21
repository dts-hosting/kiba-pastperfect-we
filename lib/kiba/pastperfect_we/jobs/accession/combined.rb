# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Accession
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__accession,
                destination: :accession__combined
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__accession_instructions_and_other_information,
                join_column: :id,
                delete_join_column: false,
                opts: {null_placeholder: "FOO"}

              transform Ppwe::Transforms::MergeTable,
                source: :prep__accession_insurance_information,
                join_column: :id,
                delete_join_column: false,
                opts: {null_placeholder: "FOO"}

              transform Ppwe::Transforms::MergeTable,
                source: :prep__accession_activities,
                join_column: :id,
                drop_fields: :id,
                delete_join_column: false,
                merged_field_prefix: "activity"
            end
          end
        end
      end
    end
  end
end
