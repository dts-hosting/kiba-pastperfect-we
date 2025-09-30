# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module IdNameClass
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__id_name_class
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Rename::Field, from: :id, to: :catalogitemid

              transform Delete::FieldsExcept,
                fields: Ppwe::CatalogItem.base_fields +
                  Ppwe::CatalogItem.id_name_class_fields

              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_lexicon,
                join_column: :catalogitemid,
                delete_join_column: false

              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: Ppwe::CatalogItem.id_name_class_fields
            end
          end
        end
      end
    end
  end
end
