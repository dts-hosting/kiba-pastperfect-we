# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Image
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__image_object,
                destination: :review__image,
                lookup: Ppwe::Image.lookup_file_config
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
              Ppwe::Image.merge_config.each do |k, v|
                transform Merge::MultiRowLookup,
                  lookup: send(Ppwe::Image.jobkey_for(k, :image)),
                  keycolumn: :id,
                  fieldmap: v[:fieldmap],
                  constantmap: v[:constantmap]
              end

              transform CombineValues::FromFieldsWithDelimiter,
                sources: Ppwe::Image.itemtype_fields,
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
