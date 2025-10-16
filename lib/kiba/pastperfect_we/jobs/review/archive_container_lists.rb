# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module ArchiveContainerLists
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__archive_container_location,
                destination: :review__archive_container_lists,
                lookup: %i[
                  prep__catalog_item
                  prep__catalog_item_multilevel_linking
                  catalog_item__base
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            [:id] + Ppwe::CatalogItem.base_fields +
              %i[parent_title parent_level container folder title description
                date yearrangefrom yearrangeto creator_name subject location
                ispublicaccess]
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: catalog_item__base,
                keycolumn: :catalogitemid,
                fieldmap: Ppwe::CatalogItem.base_fields_merge_map

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: {parent_title: :title}

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_multilevel_linking,
                keycolumn: :catalogitemid,
                fieldmap: {parent_level: :level}
            end
          end
        end
      end
    end
  end
end
