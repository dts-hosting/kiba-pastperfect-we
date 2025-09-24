# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module CustomFieldData
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__custom_field_data
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Rename::Field, from: :id, to: :catalogitemid

              content_fields = %i[
                reason_surveyed marking/cat_no glove_type ohio_county
                collection_rank naamcc_mission ohc_mission prevalence
                surveyor survey_approved_by survey_start_date
                survey_finalized_date cataloger_remarks handling_notes
                gender patent_date handling_type backlog_priority
                backlog_processing_time complexity
              ]
              transform Delete::FieldsExcept,
                fields: Ppwe::CatalogItem.base_fields + content_fields

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
