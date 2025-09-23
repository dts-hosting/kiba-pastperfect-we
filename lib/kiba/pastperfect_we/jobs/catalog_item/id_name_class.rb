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
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id itemtype itemid
                  alternativeitemid oldnumber
                  objectname othername
                  accessionid]
              transform Rename::Field, from: :id, to: :catalogitemid

              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_lexicon,
                join_column: :catalogitemid,
                delete_join_column: false
            end
          end
        end
      end
    end
  end
end
