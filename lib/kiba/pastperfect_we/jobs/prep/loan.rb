# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module Loan
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[renewedbyid datasetid]

              %i[isremoved isreturned].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              transform Ppwe::Transforms::MergeTable,
                source: :preprocess__loan_insurance_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :preprocess__loan_shipping_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_contact_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_activities,
                join_column: :id,
                delete_join_column: false,
                merged_field_prefix: "activity"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan_attachment,
                join_column: :id,
                delete_join_column: false,
                merged_field_prefix: "attachment"
            end
          end
        end
      end
    end
  end
end
