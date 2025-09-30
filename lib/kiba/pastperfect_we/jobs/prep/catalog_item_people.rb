# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemPeople
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :prep__person
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__person,
                keycolumn: :personid,
                fieldmap: {person_name: :fullname}

              transform Delete::Fields,
                fields: %i[personid]
            end
          end
        end
      end
    end
  end
end
