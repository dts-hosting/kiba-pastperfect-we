# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module CatalogItem
        module SubjectInfo
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :catalog_item__base,
                destination: :catalog_item__subject_info,
                lookup: %i[
                  prep__catalog_item_people
                  prep__catalog_item_classification
                  prep__catalog_item_subjects
                  prep__catalog_item_tags
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_people,
                keycolumn: :catalogitemid,
                fieldmap: {person: :person_name},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_classification,
                keycolumn: :catalogitemid,
                fieldmap: {classification: :classification},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_subjects,
                keycolumn: :catalogitemid,
                fieldmap: {subjects: :subjects},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_tags,
                keycolumn: :catalogitemid,
                fieldmap: {tags: :tags},
                sorter: Lookup::RowSorter.new(on: :position, as: :to_i)

              content_fields = %i[person classification subjects tags]
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
