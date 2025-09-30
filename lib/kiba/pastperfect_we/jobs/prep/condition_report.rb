# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ConditionReport
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :prep__catalog_item
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[conditionid reporttypeid conservatorid
                  createdbyuserid]

              mapping = Ppwe::CatalogItem.base_fields
                .map { |field| [field, field] }
                .to_h
              mapping.delete(:catalogitemid)

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: mapping
            end
          end
        end
      end
    end
  end
end
