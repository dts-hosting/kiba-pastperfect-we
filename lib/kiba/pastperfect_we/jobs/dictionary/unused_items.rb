# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Dictionary
        module UnusedItems
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :preprocess__dictionary_item,
                destination: :dictionary__unused_items,
                lookup: :dictionary__usage
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: dictionary__usage,
                keycolumn: :dictionaryid,
                fieldmap: {used_in: :used_in}
              transform FilterRows::FieldPopulated,
                action: :reject,
                field: :used_in
              transform Delete::Fields, fields: :used_in
            end
          end
        end
      end
    end
  end
end
