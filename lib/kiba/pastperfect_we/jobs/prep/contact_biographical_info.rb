# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ContactBiographicalInfo
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
                fields: %i[sexid maritalstatusid]

              transform Replace::FieldValueWithStaticMapping,
                source: :isdeceased,
                mapping: Ppwe.boolean_yes_no_mapping

              transform Ppwe::Transforms::CrSplitter,
                fields: %i[nicknames education titles relationships
                  publications interests affiliations]
            end
          end
        end
      end
    end
  end
end
