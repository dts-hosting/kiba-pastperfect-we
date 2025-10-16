# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemRelation
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :relation__id_lookup
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: relation__id_lookup,
                keycolumn: :relationid,
                fieldmap: {id: :id}

              transform Delete::Fields, fields: :relationid
            end
          end
        end
      end
    end
  end
end
