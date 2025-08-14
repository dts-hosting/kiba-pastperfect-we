# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module LoanCatalogItems
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__exhibit_catalog_items,
                destination: :exhibit_catalog_items__combined,
                lookup: %i[prep__catalog_item prep__exhibit]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :loanid,
                fieldmap: {itemidnormalized: :itemidnormalized,
                           objectname: :lexicon_item_objectname}

              transform Merge::MultiRowLookup,
                lookup: prep__loan,
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
