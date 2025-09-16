# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Exhibit
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__exhibit,
                destination: :exhibit__combined,
                lookup: %i[]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__exhibit_insurance_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :preprocess__exhibit_shipping_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :preprocess__exhibit_security,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__exhibit_attachment,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id,
                merged_field_prefix: "attachment"
            end
          end
        end
      end
    end
  end
end
