# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LoanCatalogItems
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[
                  prep__catalog_item
                  prep__loan
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Replace::FieldValueWithStaticMapping,
                source: :isreturned,
                mapping: Ppwe.boolean_yes_no_mapping
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: Ppwe::CatalogItem.base_fields_merge_map
              transform Merge::MultiRowLookup,
                lookup: prep__loan,
                keycolumn: :loanid,
                fieldmap: {loannumberandrecipient: :loannumberandrecipient}
            end
          end
        end
      end
    end
  end
end
