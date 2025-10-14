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
                source: :catalog_item__base,
                destination: :catalog_item__archaeology,
                lookup: %i[
                  prep__catalog_item_archaeology_material
                  prep__catalog_item_repatriation
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_archaeology,
                join_column: :catalogitemid,
                delete_join_column: false
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_archaeology_material,
                keycolumn: :catalogitemid,
                fieldmap: {material: :material},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)
              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_repatriation,
                join_column: :catalogitemid,
                delete_join_column: false,
                merged_field_prefix: "repatriation"

              content_fields = Ppwe.mergeable_headers_for(
                :prep__catalog_item_archaeology
              ) +
                Ppwe.mergeable_headers_for(
                 :prep__catalog_item_repatriation
               ).map { |f| :"repatriation_#{f}" } +
                [:material]

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
