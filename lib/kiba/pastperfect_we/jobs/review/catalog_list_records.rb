# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module CatalogListRecords
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_list_records,
                destination: :review__catalog_list_records
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
