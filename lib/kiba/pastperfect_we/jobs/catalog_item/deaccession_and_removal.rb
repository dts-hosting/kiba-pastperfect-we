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
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Rename::Field, from: :id, to: :catalogitemid

              transform Delete::FieldsExcept,
                fields: Ppwe::CatalogItem.base_fields +
                  Ppwe::CatalogItem.deaccession_and_removal_fields

              transform Delete::FieldValueMatchingRegexp,
                fields: :isremoved,
                match: /^no$/

              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: Ppwe::CatalogItem.deaccession_and_removal_fields

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
