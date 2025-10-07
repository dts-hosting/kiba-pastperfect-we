# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module InventoryHistory
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__inventory_history,
                destination: :review__inventory_history
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            [:id] + Ppwe::CatalogItem.base_fields
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :catalog_item__base,
                join_column: :catalogitemid,
                delete_join_column: false
            end
          end
        end
      end
    end
  end
end
