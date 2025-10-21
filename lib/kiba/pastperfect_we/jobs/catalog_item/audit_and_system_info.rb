# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module AuditAndSystemInfo
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__audit_and_system_info,
                lookup: %i[
                  prep__catalog_item_notes_and_legal
                  prep__catalog_item_url
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
                  Ppwe::CatalogItem.audit_and_system_info_fields

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_notes_and_legal,
                keycolumn: :catalogitemid,
                fieldmap: {webright: :webright}

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_url,
                keycolumn: :catalogitemid,
                fieldmap: Ppwe::Url.fieldmap

              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: Ppwe::CatalogItem.audit_and_system_info_fields
            end
          end
        end
      end
    end
  end
end
