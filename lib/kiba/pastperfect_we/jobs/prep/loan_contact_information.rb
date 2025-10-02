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
              prefix_needed = %i[address1 address2 city state zip notes
                primaryphonenumber primaryphonenumbertype
                secondaryphonenumber secondaryphonenumbertype
                otherphonenumber otherphonenumbertype email
                website countryid]
              to_prefix = prefix_needed.intersection(
                Ppwe.mergeable_headers_for(
                  :preprocess__loan_contact_information
                )
              )
              prefix_mapping = to_prefix.map { |f| [f, :"contact#{f}"] }
                .to_h
              transform Rename::Fields, fieldmap: prefix_mapping

              transform Ppwe::Transforms::DictionaryLookup,
                fields: :contactcountryid

              %i[contactprimaryphonenumbertype contactsecondaryphonenumbertype
                contactotherphonenumbertype].each do |field|
                numfield = field.to_s.delete_suffix("type").to_sym
                transform Delete::FieldValueConditional,
                  fields: field,
                  lambda: ->(val, row) { row[numfield].blank? }

                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe::Enums.phone_number_type,
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
