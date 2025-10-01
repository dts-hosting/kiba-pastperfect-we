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
                destination: dest
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

                if Ppwe.mode == :review
                  transform CombineValues::FromFieldsWithDelimiter,
                    sources: %i[loannumber loanedto],
                    target: :loannumberandrecipient,
                    delete_sources: false,
                    delim: ", to: "
                end
              end
            end
          end
        end
      end
    end
  end
end
