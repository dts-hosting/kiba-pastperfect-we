# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemLocation
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: get_lookups
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def get_lookups
            return [] if Ppwe.mode == :migration

            [:location__prefixed]
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[datasetid inventoriedbyid]

              transform Clean::RegexpFindReplaceFieldVals,
                fields: %i[latitude longitude],
                find: /^\.00000$/,
                replace: ""
              transform Clean::RegexpFindReplaceFieldVals,
                fields: %i[azimuth],
                find: /^0$/,
                replace: ""

              transform Replace::FieldValueWithStaticMapping,
                source: :isattemplocation,
                mapping: Ppwe.boolean_yes_no_mapping

              if Ppwe.mode == :review
                %w[homelocation templocation].each do |base|
                  transform Merge::MultiRowLookup,
                    lookup: location__prefixed,
                    keycolumn: :"#{base}id",
                    fieldmap: {"#{base}": Ppwe::Terms.table_config["Location"]}
                  transform Delete::Fields,
                    fields: :"#{base}id"
                end
              end
            end
          end
        end
      end
    end
  end
end
