# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module Accession
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest

              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[statusid receivedasid interumlocationid receivedbyid
                  accessionedbyid renewedbyid]

              %i[displayrestrictedflagforcatalogitems isremoved].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end
            end
          end
        end
      end
    end
  end
end
