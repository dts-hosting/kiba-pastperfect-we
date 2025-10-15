# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module Source
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :catalog_item__source,
                lookup: :preprocess__catalog_item
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: preprocess__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: {accessionid: :accessionid}
              transform FilterRows::FieldPopulated,
                action: :reject,
                field: :accessionid

              transform Ppwe::Transforms::MergeTable,
                source: :prep__catalog_item_source,
                join_column: :catalogitemid,
                delete_join_column: false

              content_fields = Ppwe.mergeable_headers_for(
                :prep__catalog_item_source
              )
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
