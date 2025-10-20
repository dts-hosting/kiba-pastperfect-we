# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Attachment
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__attachment,
                destination: :review__attachment,
                lookup: Ppwe::Attachment.lookup_file_config
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            hdrs = %i[id]
            hdrs << Ppwe::Splitting.item_type_field
            hdrs << Ppwe.review_target_field
            hdrs
          end

          def xforms
            Kiba.job_segment do
              Ppwe::Attachment.merge_config.each do |k, v|
                transform Merge::MultiRowLookup,
                  lookup: send(Ppwe::Attachment.jobkey_for(k, :attachment)),
                  keycolumn: :id,
                  fieldmap: v[:fieldmap],
                  constantmap: v[:constantmap]
              end

              transform CombineValues::FromFieldsWithDelimiter,
                sources: Ppwe::Attachment.itemtype_fields,
                target: Ppwe::Splitting.item_type_field,
                delete_sources: false,
                delim: Ppwe.delim
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: "|"
              transform Ppwe::Transforms::ReviewTargetFieldMerger
            end
          end
        end
      end
    end
  end
end
