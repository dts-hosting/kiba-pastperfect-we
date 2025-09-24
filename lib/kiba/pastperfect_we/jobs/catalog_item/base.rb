# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module Base
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__base
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Rename::Field, from: :id, to: :catalogitemid
              transform Delete::FieldsExcept,
                fields: Ppwe::CatalogItem.base_fields
            end
          end
        end
      end
    end
  end
end
