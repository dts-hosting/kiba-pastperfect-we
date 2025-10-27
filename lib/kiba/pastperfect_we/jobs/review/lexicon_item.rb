# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module LexiconItem
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__lexicon_item,
                destination: :review__lexicon_item,
                lookup: :target_system_lookup__lexicon_item
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "LexiconItem"
              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__lexicon_item,
                keycolumn: :id,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                }
              transform Ppwe::Transforms::ReviewTargetFieldMerger
            end
          end
        end
      end
    end
  end
end
