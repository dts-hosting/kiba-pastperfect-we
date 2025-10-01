# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LoanShippingInformation
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
                source: :transportationcostpaidby,
                mapping: Ppwe::Enums.responsible_party,
                delete_source: false,
                fallback_val: nil
              transform Delete::FieldValueMatchingRegexp,
                fields: :noofcrates,
                match: /^0$/
            end
          end
        end
      end
    end
  end
end
