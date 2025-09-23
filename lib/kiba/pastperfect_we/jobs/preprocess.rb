# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      # Deletes fields/columns where all values are blank, and deletes rows
      #  where only the first field/column is non-blank
      module Preprocess
        module_function

        def job(source:, dest:, tablename:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: source,
              destination: dest

            },
            transformer: xforms(tablename)
          )
        end

        def xforms(tablename)
          Kiba.job_segment do
            transform Delete::Fields, fields: Ppwe::Preprocess.delete_fields

            transform Clean::RegexpFindReplaceFieldVals,
              fields: :all,
              find: /^0\.00$/,
              replace: ""
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :all,
              find: /^\.0+$/,
              replace: ""
            transform Delete::EmptyFields

            unless Ppwe::Preprocess.keep_id_only_field_populated_tables
                .include?(tablename)
              transform do |row|
                next if row.keys.length == 1

                chk = row.dup
                chk.shift
                row unless chk.all? { |field, val| val.blank? }
              end
            end

            transform Ppwe::Transforms::DeleteTimestamps
          end
        end
      end
    end
  end
end
