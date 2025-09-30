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
                destination: :review__lexicon_item
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "LexiconItem"
            end
          end
        end
      end
    end
  end
end
