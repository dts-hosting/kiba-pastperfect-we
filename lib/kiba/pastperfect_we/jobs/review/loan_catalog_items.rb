# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module LoanCatalogItems
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__loan_catalog_items,
                destination: :review__loan_catalog_items,
                lookup: %i[prep__catalog_item prep__loan]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__loan,
                join_column: :loanid,
                drop_fields: :id,
                delete_join_column: false,
                merged_field_prefix: "loan"

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: {itemidnormalized: :itemidnormalized,
                           objectname: :lexicon_item_objectname}
            end
          end
        end
      end
    end
  end
end
