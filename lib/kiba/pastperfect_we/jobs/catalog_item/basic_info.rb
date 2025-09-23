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
                lookup: :prep__catalog_item_location
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id itemtype itemid
                  objectname title description
                  creationdate yearrangefrom yearrangeto
                  dimensionsummary collection accessionnumber
                  status deaccessioned isremoved]
              transform Rename::Field, from: :id, to: :catalogitemid

              %i[homelocation templocation].each do |field|
                transform Merge::MultiRowLookup,
                  lookup: prep__catalog_item_location,
                  keycolumn: :catalogitemid,
                  fieldmap: {field => field}
              end
            end
          end
        end
      end
    end
  end
end
