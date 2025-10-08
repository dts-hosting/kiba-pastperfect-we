# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Exhibit
        module TargetSystemLookup
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :preprocess__exhibit,
                destination: :exhibit__target_system_lookup,
                lookup: [
                  {jobkey: :preprocess__exhibit_catalog_items,
                   lookup_on: :exhibitid},
                  :prep__catalog_item
                ]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id exhibitname]
              transform Merge::MultiRowLookup,
                lookup: preprocess__exhibit_catalog_items,
                keycolumn: :id,
                fieldmap: {catalogitemid: :catalogitemid}
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: {Ppwe::Splitting.item_type_field =>
                           Ppwe::Splitting.item_type_field},
                multikey: true
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: Ppwe.delim
              transform Deduplicate::Table,
                field: :id,
                compile_uniq_fieldvals: true
              transform Ppwe::Transforms::ReviewTargetFieldMerger
              transform Delete::Fields, fields: :catalogitemid
            end
          end
        end
      end
    end
  end
end
