# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LexiconItem
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              %i[isremoved isstandard isdeleted].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              transform Replace::FieldValueWithStaticMapping,
                source: :objectnametypeid,
                mapping: Ppwe::Enums.object_name_type,
                target: :objectnametype

              transform Ppwe::Transforms::MergeTable,
                source: :prep__category,
                join_column: :categoryid,
                drop_fields: :id,
                merged_field_prefix: "category"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__classification,
                join_column: :classificationid,
                drop_fields: %i[id category category_name category_definition
                  category_issystemcategory],
                merged_field_prefix: "classification"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__sub_classification,
                join_column: :subclassificationid,
                drop_fields: %i[id classification classification_name
                  classification_definition classification_category_name
                  classification_category_definition
                  classification_category_issystemcategory],
                merged_field_prefix: "subclassification"

              if Ppwe.mode == :review
                getter =
                  Kiba::Extend::Transforms::Helpers::FieldValueGetter.new(
                  fields: %i[tertiary secondary primary
                    subclassification_name
                    classification_name
                    category_name]
                )
                transform do |row|
                  term = row[:objectname]
                  hier = getter.call(row)
                    .reject { |k, v| v == term }
                    .values
                    .join(" < ")
                  row[:objectname] = [term, hier].join(" < ")
                  row
                end
              end
            end
          end
        end
      end
    end
  end
end
