# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module ConditionReport
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__condition_report,
                destination: :review__condition_report,
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
                fieldmap: {cleanlinessstate: :dictionaryitem,
                           cleanlinessstate_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_materials_condition,
                keycolumn: :id,
                fieldmap: {materialscondition: :dictionaryitem,
                           materialscondition_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_parts_condition,
                keycolumn: :id,
                fieldmap: {partscondition: :dictionaryitem,
                           partscondition_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_structure_condition,
                keycolumn: :id,
                fieldmap: {structurecondition: :dictionaryitem,
                           structurecondition_desc: :dictionaryitem_desc}

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_surface_condition,
                keycolumn: :id,
                fieldmap: {surfacecondition: :dictionaryitem,
                           surfacecondition_desc: :dictionaryitem_desc}
            end
          end
        end
      end
    end
  end
end
