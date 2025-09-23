# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemMusic
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
                fields: %i[genreid recordingmediaid
                  instrumentid]

              transform Merge::MultiRowLookup,
                lookup: prep__person,
                keycolumn: :primaryartistid,
                fieldmap: {primaryartist: :fullname}

              transform Delete::Fields,
                fields: %i[primaryartistid]
            end
          end
        end
      end
    end
  end
end
