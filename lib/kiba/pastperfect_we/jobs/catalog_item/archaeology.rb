# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module Archaeology
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__archaeology,
                lookup: :prep__catalog_item_archaeology_material
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id itemtype itemid]

              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_archaeology,
                join_column: :id,
                delete_join_column: false
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_archaeology_material,
                keycolumn: :id,
                fieldmap: {material: :material},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)

              content_fields = Ppwe.mergeable_headers_for(
                :prep__catalog_item_archaeology
              ) + [:material]
              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: content_fields
            end
          end
        end
      end
    end
  end
end
