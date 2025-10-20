# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module TargetSystemLookup
        module CatalogItem
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :target_system_lookup__catalog_item
              },
              transformer: xforms
            )
          end

          def xforms = nil
        end
      end
    end
  end
end
