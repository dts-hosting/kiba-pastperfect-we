# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemLibrary
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
                fields: %i[authorid publisherid publishedplaceid seriesid
                  languageid eventid]
              transform Ppwe::Transforms::CrSplitter,
                fields: %i[titleaddedentry authoraddedentry seriesaddedentry]
              if Ppwe.mode == :review
                transform Merge::MultiRowLookup,
                  lookup: prep__site,
                  keycolumn: :siteid,
                  fieldmap: {site: Ppwe::Terms.table_config["Site"]}

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
