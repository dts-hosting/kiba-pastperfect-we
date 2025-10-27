# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Location
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__location,
                destination: :review__location,
                lookup: %i[
                  location__prefixed
                  target_system_lookup__location
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: location__prefixed,
                keycolumn: :id,
                fieldmap: {location: :location}
              transform Deduplicate::Table,
                field: :location,
                compile_uniq_fieldvals: true,
                compile_delim: Ppwe.delim,
                include_occs: true
              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__location,
                keycolumn: :id,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                },
                multikey: true
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: Ppwe.delim
              transform Ppwe::Transforms::ReviewTargetFieldMerger

              fields = Ppwe::Jobs::Location::Prefixed.field_name_lookup.keys
              transform CombineValues::FromFieldsWithDelimiter,
                sources: fields,
                target: :displaylocation,
                delete_sources: false,
                delim: ", "
              transform Sort::ByFieldValue,
                field: :displaylocation,
                mode: :string
              transform Deduplicate::FlagAll,
                on_field: :displaylocation,
                in_field: :duplicatedisplayloc,
                explicit_no: false
            end
          end
        end
      end
    end
  end
end
