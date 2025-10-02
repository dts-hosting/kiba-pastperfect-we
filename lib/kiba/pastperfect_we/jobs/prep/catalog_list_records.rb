# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogListRecords
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[
                  prep__catalog_item
                  prep__catalog_list
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: Ppwe::CatalogItem.base_fields_merge_map
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_list,
                keycolumn: :cataloglistid,
                fieldmap: {
                  listname: :listname,
                  listcategory: :listcategory
                }
              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[listcategory listname],
                target: :listcategoryandname,
                delim: " > "
            end
          end
        end
      end
    end
  end
end
