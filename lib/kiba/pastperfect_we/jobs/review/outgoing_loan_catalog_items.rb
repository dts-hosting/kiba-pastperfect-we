# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module OutgoingLoanCatalogItems
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__loan_catalog_items,
                destination: :review__outgoing_loan_catalog_items
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms = nil
        end
      end
    end
  end
end
