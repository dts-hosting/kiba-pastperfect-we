# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module BasicInfo
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__basic_info,
                lookup: %i[
                  prep__catalog_item_dimensions
                  prep__catalog_item_location
                ]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Rename::Field, from: :id, to: :catalogitemid

              transform Delete::FieldsExcept,
                fields: Ppwe::CatalogItem.base_fields +
                  Ppwe::CatalogItem.basic_info_fields

              %i[homelocation templocation].each do |field|
                transform Merge::MultiRowLookup,
                  lookup: prep__catalog_item_location,
                  keycolumn: :catalogitemid,
                  fieldmap: {field => field}
              end

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_dimensions,
                keycolumn: :catalogitemid,
                fieldmap: {dimensions: :details}
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_dimensions,
                keycolumn: :catalogitemid,
                fieldmap: {itemcount: :count}
            end
          end
        end
      end
    end
  end
end
