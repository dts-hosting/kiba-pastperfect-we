# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module ConditionReport
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__condition_report,
                destination: :condition_report__combined,
                lookup: %i[
                  prep__condition_report_cleanliness_state
                  prep__condition_report_materials_condition
                  prep__condition_report_parts_condition
                  prep__condition_report_structure_condition
                  prep__condition_report_surface_condition
                ]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_cleanliness_state,
                keycolumn: :id,
                fieldmap: {state_of_cleanliness: :dictionaryitem,
                           state_of_cleanliness_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_materials_condition,
                keycolumn: :id,
                fieldmap: {condition_of_materials: :dictionaryitem,
                           condition_of_materials_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_parts_condition,
                keycolumn: :id,
                fieldmap: {condition_of_parts: :dictionaryitem,
                           condition_of_parts_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_structure_condition,
                keycolumn: :id,
                fieldmap: {condition_of_structure: :dictionaryitem,
                           condition_of_structure_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_surface_condition,
                keycolumn: :id,
                fieldmap: {condition_of_surface: :dictionaryitem,
                           condition_of_surface_desc: :dictionaryitem_desc}
            end
          end
        end
      end
    end
  end
end
