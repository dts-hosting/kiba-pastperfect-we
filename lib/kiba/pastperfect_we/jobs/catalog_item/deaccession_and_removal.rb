# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module DeaccessionAndRemoval
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__catalog_item,
                destination: :catalog_item__deaccession_and_removal
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              content_fields = %i[
                deaccessioned deaccessiondate deaccessionreasonnotes
                deaccessionauthorizedbyuser isremoved removaldate
                disposaldate disposalmethod
              ]
              transform Delete::FieldsExcept,
                fields: %i[id itemtype itemid] + content_fields
              transform Rename::Field, from: :id, to: :catalogitemid
              transform Delete::FieldValueMatchingRegexp,
                fields: :isremoved,
                match: /^no$/

              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: content_fields

              transform do |row|
                next row unless row[:isremoved].blank?

                row[:isremoved] = "no"
                row
              end
            end
          end
        end
      end
    end
  end
end
