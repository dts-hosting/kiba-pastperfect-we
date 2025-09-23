# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemArchaeology
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

            %i[prep__site]
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[datingmethodid collectorid excavatedbyid
                  identifiedbyid]

              if Ppwe.mode == :review
                transform Merge::MultiRowLookup,
                  lookup: prep__site,
                  keycolumn: :siteid,
                  fieldmap: {sitename: :sitename}

                transform Delete::Fields,
                  fields: %i[siteid]
              end
            end
          end
        end
      end
    end
  end
end
