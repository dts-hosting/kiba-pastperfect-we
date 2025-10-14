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
                lookup: [
                  :prep__condition_report_cleanliness_state,
                  :prep__condition_report_materials_condition,
                  :prep__condition_report_parts_condition,
                  :prep__condition_report_structure_condition,
                  :prep__condition_report_surface_condition,
                  {
                    jobkey: :preprocess__condition_report_image,
                    lookup_on: :conditionreportid
                  },
                  {
                    jobkey: :condition_report__target_system_lookup,
                    lookup_on: :id
                  }
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              {
                prep__condition_report_cleanliness_state: :cleanlinessstate,
                prep__condition_report_materials_condition: :materialscondition,
                prep__condition_report_parts_condition: :partscondition,
                prep__condition_report_structure_condition: :structurecondition,
                prep__condition_report_surface_condition: :surfacecondition
              }.each do |lkup, field|
                transform Merge::MultiRowLookup,
                  lookup: send(lkup),
                  keycolumn: :id,
                  fieldmap: {field => field},
                  sorter: Lookup::RowSorter.new(on: :position, as: :to_i)
              end

              transform Count::MatchingRowsInLookup,
                lookup: preprocess__condition_report_image,
                keycolumn: :id,
                targetfield: :numberofimages
              transform Merge::MultiRowLookup,
                lookup: condition_report__target_system_lookup,
                keycolumn: :id,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field,
                  Ppwe.review_target_field => Ppwe.review_target_field,
                  :itemid => :itemid
                }
            end
          end
        end
      end
    end
  end
end
