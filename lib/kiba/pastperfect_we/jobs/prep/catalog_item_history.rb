# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemHistory
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[
                  prep__person
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[creatorroleid eventid usageid ownerid madeid
                  collectorid]

              transform Merge::MultiRowLookup,
                lookup: prep__person,
                keycolumn: :creatorid,
                fieldmap: {creator: Ppwe::Terms.table_config["Person"]}

              transform Delete::Fields,
                fields: %i[creatorid]
            end
          end
        end
      end
    end
  end
end
