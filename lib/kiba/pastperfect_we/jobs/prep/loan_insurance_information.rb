# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LoanInsuranceInformation
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
              transform Replace::FieldValueWithStaticMapping,
                source: :insuredby,
                mapping: Ppwe::Enums.responsible_party,
                delete_source: false,
                fallback_val: nil
              prefix_needed = %i[representative phonenumber premium]
              to_prefix = prefix_needed.intersection(
                Ppwe.mergeable_headers_for(
                  :preprocess__loan_insurance_information
                )
              )
              prefix_mapping = to_prefix.map { |f| [f, :"insurance#{f}"] }
                .to_h
              transform Rename::Fields, fieldmap: prefix_mapping
            end
          end
        end
      end
    end
  end
end
