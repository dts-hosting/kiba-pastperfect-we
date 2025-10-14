# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module ProceduralAndHandling
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__procedural_and_handling,
                lookup: %i[
                  prep__catalog_item_condition
                  prep__flag
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Rename::Field, from: :id, to: :catalogitemid

              transform Delete::FieldsExcept,
                fields: Ppwe::CatalogItem.base_fields +
                  Ppwe::CatalogItem.procedural_and_handling_fields +
                  [:flagid]

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_condition,
                keycolumn: :catalogitemid,
                fieldmap: {
                  conditiondate: :conditiondate,
                  conditionmaintenanceperiodicity: :maintenanceperiodicity,
                  conditionmaintenancestartdate: :maintenancestartdate,
                  conditionmaintenancenotes: :maintenancenotes,
                  generalconditionnotes: :generalconditionnotes,
                  condition: :condition,
                  conditiondisplayvalue: :displayvalue
                }
              transform Merge::MultiRowLookup,
                lookup: prep__flag,
                keycolumn: :flagid,
                fieldmap: {
                  flagdate: :date,
                  flagreason: :reason,
                  flagdetails: :details
                }
              transform Delete::Fields, fields: :flagid
            end
          end
        end
      end
    end
  end
end
