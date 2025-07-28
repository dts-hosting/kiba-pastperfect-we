# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Dictionary
        module Usage
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :preprocess__dictionary_item,
                destination: :dictionary__usage,
                lookup: :dictionary__filters
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: :dictionaryid
              transform Deduplicate::Table,
                field: :dictionaryid
              transform Merge::MultiRowLookup,
                lookup: dictionary__filters,
                keycolumn: :dictionaryid,
                fieldmap: {used_in: :fieldname}
              transform Count::FieldValues,
                field: :used_in,
                target: :used_in_ct,
                delim: Ppwe.delim
              transform Sort::ByFieldValue,
                field: :used_in_ct,
                order: :desc
            end
          end
        end
      end
    end
  end
end
