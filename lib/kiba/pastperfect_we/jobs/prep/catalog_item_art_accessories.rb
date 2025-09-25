# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemArtAccessories
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
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[dictionaryitemid]

              transform Rename::Field,
                from: :dictionaryitem,
                to: :accessories

              transform Delete::Fields,
                fields: %i[position id]
            end
          end
        end
      end
    end
  end
end
