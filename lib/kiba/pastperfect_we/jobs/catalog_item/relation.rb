# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module Relation
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :catalog_item__relation,
                lookup: [
                  :prep__catalog_item_relation,
                  {
                    jobkey: :prep__catalog_item_relation,
                    lookup_on: :id,
                    name: :rels_by_id
                  },
                  :catalog_item__base
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_relation,
                keycolumn: :catalogitemid,
                fieldmap: {
                  relatedpublications: :relatedpublications,
                  relateditemnotes: :notes,
                  relateditemsetid: :id
                }
              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: %i[relatedpublications relateditemnotes
                  relateditemsetid]

              transform Merge::MultiRowLookup,
                lookup: rels_by_id,
                keycolumn: :relateditemsetid,
                fieldmap: {relatedcatalogitemid: :catalogitemid},
                conditions: ->(r, rows) do
                  rows.reject { |mr| mr[:catalogitemid] == r[:catalogitemid] }
                end

              transform Merge::MultiRowLookup,
                lookup: catalog_item__base,
                keycolumn: :relatedcatalogitemid,
                fieldmap: {relateditemtype: :itemtype},
                multikey: true
              transform Deduplicate::FieldValues,
                fields: :relateditemtype,
                sep: Ppwe.delim
              transform Ppwe::Transforms::ReviewTargetFieldMerger,
                source: :relateditemtype,
                target: :relatedtargetsystems
              transform Delete::FieldValueMatchingRegexp,
                fields: :relatedtargetsystems,
                match: /^no associated items$/
            end
          end
        end
      end
    end
  end
end
