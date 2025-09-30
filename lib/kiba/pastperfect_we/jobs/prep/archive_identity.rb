# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ArchiveIdentity
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[
                  prep__person
                  prep__site
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[eventid multilevelid]

              transform Merge::MultiRowLookup,
                lookup: prep__person,
                keycolumn: :creatorid,
                fieldmap: {creator_name: Ppwe::Terms.table_config["Person"]}

              transform Merge::MultiRowLookup,
                lookup: prep__site,
                keycolumn: :siteid,
                fieldmap: {sitename: Ppwe::Terms.table_config["Site"]}

              transform Delete::Fields,
                fields: :creatorid

              transform Ppwe::Transforms::CrSplitter,
                fields: :creatoraddedentry
            end
          end
        end
      end
    end
  end
end
