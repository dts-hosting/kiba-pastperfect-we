# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module Site
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
              %i[ispublicaccess isremoved].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[countryid]

              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[sitenumber sitename],
                target: :sitenumberandname,
                delete_sources: false,
                delim: ": "
            end
          end
        end
      end
    end
  end
end
