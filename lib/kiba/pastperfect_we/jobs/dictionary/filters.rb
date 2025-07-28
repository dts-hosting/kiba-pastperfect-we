# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Dictionary
        module Filters
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :preprocess__filter_metadata,
                destination: :dictionary__filters
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform FilterRows::WithLambda,
                action: :keep,
                lambda: ->(row) { row[:parameter]&.start_with?("dic.") }
              transform Delete::Fields, fields: :fieldtype
              transform Clean::RegexpFindReplaceFieldVals,
                fields: :parameter,
                find: /^dic\./,
                replace: ""
              transform Rename::Field,
                from: :parameter,
                to: :dictionaryid
            end
          end
        end
      end
    end
  end
end
