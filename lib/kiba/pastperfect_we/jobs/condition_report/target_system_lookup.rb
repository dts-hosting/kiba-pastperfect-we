# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module ConditionReport
        module TargetSystemLookup
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :preprocess__condition_report,
                destination: :condition_report__target_system_lookup,
                lookup: :prep__catalog_item
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id catalogitemid]
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :id,
                fieldmap: {Ppwe::Splitting.item_type_field =>
                           Ppwe::Splitting.item_type_field,
                           :itemid => :itemid}
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: Ppwe.delim
              transform Ppwe::Transforms::ReviewTargetFieldMerger
            end
          end
        end
      end
    end
  end
end
