# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Accession
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__accession,
                destination: :review__accession,
                lookup: %i[
                  accession__target_system_lookup
                  prep__accession_attachment
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            acc_hdrs = %i[id accessiontype number]
            acc_hdrs << Ppwe.review_target_field if Ppwe.mode == :review
            acc_hdrs
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__accession_instructions_and_other_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__accession_insurance_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__accession_shipping_information,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__accession_donors,
                join_column: :id,
                drop_fields: :id,
                delete_join_column: false,
                merged_field_prefix: "donors"

              transform Count::MatchingRowsInLookup,
                lookup: prep__accession_attachment,
                keycolumn: :id,
                targetfield: :attachment_count

              transform Merge::MultiRowLookup,
                lookup: accession__target_system_lookup,
                keycolumn: :id,
                fieldmap: {Ppwe.review_target_field => Ppwe.review_target_field}
            end
          end
        end
      end
    end
  end
end
