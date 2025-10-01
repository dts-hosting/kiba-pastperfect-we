# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LoanContactInformation
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
              transform Ppwe::Transforms::DictionaryLookup,
                fields: :countryid

              %i[primaryphonenumbertype secondaryphonenumbertype
                otherphonenumbertype].each do |field|
                numfield = field.to_s.delete_suffix("type").to_sym
                transform Delete::FieldValueConditional,
                  fields: field,
                  lambda: ->(val, row) { row[numfield].blank? }

                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe::Enums.phone_number_type,
                  # target: field.to_s.delete_suffix("id").to_sym,
                  delete_source: false,
                  fallback_val: nil
              end
            end
          end
        end
      end
    end
  end
end
