# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module ArchiveContainerLists
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__archive_container_location,
                destination: :catalog_item__archive_container_lists,
                lookup: %i[
                  prep__catalog_item
                  prep__catalog_item_multilevel_linking
                ]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: {title: :parent_title}

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_multilevel_linking,
                keycolumn: :catalogitemid,
                fieldmap: {level: :parent_level}
            end
          end
        end
      end
    end
  end
end
