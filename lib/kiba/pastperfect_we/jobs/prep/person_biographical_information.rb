# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module PersonBiographicalInformation
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
                fields: %i[sexid maritalstatusid]

              transform Replace::FieldValueWithStaticMapping,
                source: :isdeceased,
                mapping: Ppwe.boolean_yes_no_mapping

              transform Ppwe::Transforms::CrSplitter,
                fields: %i[nicknames education titlesandhonors relationships
                  placesofresidence employerandoccupation publications
                  affiliations spouses children]
            end
          end
        end
      end
    end
  end
end
