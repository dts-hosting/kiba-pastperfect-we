# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Site
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__site,
                destination: :review__site,
                lookup: :target_system_lookup__site
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Site"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__site_archeology_details,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__site_mapping_options,
                join_column: :id,
                delete_join_column: false

              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__site,
                keycolumn: :id,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                }
              transform Ppwe::Transforms::ReviewTargetFieldMerger
              transform Deduplicate::FlagAll,
                on_field: :sitenumberandname,
                in_field: :duplicatesitenumberandname,
                explicit_no: false
            end
          end
        end
      end
    end
  end
end
