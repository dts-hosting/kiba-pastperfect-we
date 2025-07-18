# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      # Deletes fields/columns where all values are blank, and deletes rows
      #  where only the first field/column is non-blank
      module Preprocess
        module_function

        def job(source:, dest:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: source,
              destination: dest

            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::EmptyFields

            transform Delete::Fields, fields: Ppwe::Preprocess.delete_fields

            transform do |row|
              next row if row.keys.length == 1

              chk = row.dup
              chk.shift
              row unless chk.all? { |field, val| val.blank? }
            end
          end
        end
      end
    end
  end
end
