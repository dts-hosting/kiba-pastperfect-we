# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ContactAddressAndPhoneNumbers
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
                fields: %i[countryid secondarycountryid]

              %i[stopmail emailnewsletter].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              %i[primaryphonenumbertypeid secondaryphonenumbertypeid
                otherphonenumber1typeid
                otherphonenumber2typeid].each do |field|
                numfield = field.to_s.delete_suffix("typeid").to_sym
                transform Delete::FieldValueConditional,
                  fields: field,
                  lambda: ->(val, row) { row[numfield].blank? }

                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe::Enums.phone_number_type,
                  target: field.to_s.delete_suffix("id").to_sym,
                  delete_source: true,
                  fallback_val: nil
              end

              transform Delete::EmptyFields
            end
          end
        end
      end
    end
  end
end
