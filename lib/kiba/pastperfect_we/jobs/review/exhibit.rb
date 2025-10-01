# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Exhibit
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__exhibit,
                destination: :review__exhibit,
                lookup: :prep__exhibit_attachment
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__exhibit_insurance_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__exhibit_shipping_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__exhibit_security,
                join_column: :id,
                delete_join_column: false

              transform Count::MatchingRowsInLookup,
                lookup: prep__exhibit_attachment,
                keycolumn: :id,
                targetfield: :numberofattachments
            end
          end
        end
      end
    end
  end
end
