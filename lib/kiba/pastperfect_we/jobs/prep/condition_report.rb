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
                lookup: %i[
                  prep__catalog_item
                  prep__condition_report_cleanliness_state
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[conditionid reporttypeid conservatorid
                  createdbyuserid]

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: {catalog_item_itemidnormalized: :itemidnormalized,
                           catalog_item_objectname: :lexicon_item_objectname}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_cleanliness_state,
                keycolumn: :id,
                fieldmap: {stateofcleanliness: :dictionaryitem}
            end
          end
        end
      end
    end
  end
end
