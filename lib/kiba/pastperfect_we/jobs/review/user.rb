# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module User
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__user,
                destination: :review__user,
                lookup: :target_system_lookup__user
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "User"
              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__user,
                keycolumn: :userid,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                }
              transform Ppwe::Transforms::ReviewTargetFieldMerger
              transform Deduplicate::FlagAll,
                on_field: :fullname,
                in_field: :duplicatefullname,
                explicit_no: false
              transform Sort::ByFieldValue,
                field: :fullname,
                mode: :string
            end
          end
        end
      end
    end
  end
end
