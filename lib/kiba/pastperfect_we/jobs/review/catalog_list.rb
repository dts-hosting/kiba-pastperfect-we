# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module CatalogList
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_list,
                destination: :review__catalog_list,
                lookup: :prep__catalog_list_records
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_list_records,
                keycolumn: :id,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                }

              transform Deduplicate::FieldValues,
                fields: :itemtype,
                sep: Ppwe.delim

              transform Ppwe::Transforms::ReviewTargetFieldMerger

              transform Count::MatchingRowsInLookup,
                lookup: prep__catalog_list_records,
                keycolumn: :id,
                targetfield: :numberofrecordsinlist
            end
          end
        end
      end
    end
  end
end
