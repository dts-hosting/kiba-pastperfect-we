# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemNaturalHistory
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[
                  prep__site
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[habitatid sexid eraid epochid periodid stageid
                  kingdomid subfamilyid phylumid genusid classid
                  speciesid orderid subspeciesid familyid collectorid
                  preparedbyid identifiedbyid]

              transform Merge::MultiRowLookup,
                lookup: prep__site,
                keycolumn: :siteid,
                fieldmap: {sitename: Ppwe::Terms.table_config["Site"]}
              transform Delete::Fields,
                fields: %i[siteid]
            end
          end
        end
      end
    end
  end
end
