# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module TargetSystemLookup
        module Attachment
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :review__attachment,
                destination: :target_system_lookup__attachment
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id] + Ppwe::Attachment.itemtype_fields
              transform CombineValues::FromFieldsWithDelimiter,
                sources: Ppwe::Attachment.itemtype_fields,
                target: Ppwe::Splitting.item_type_field,
                delete_sources: true,
                delim: Ppwe.delim
              transform Delete::EmptyFieldValues,
                fields: Ppwe::Splitting.item_type_field,
                delim: Ppwe.delim
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: Ppwe.delim
              transform Ppwe::Transforms::ReviewTargetFieldMerger
            end
          end
        end
      end
    end
  end
end
