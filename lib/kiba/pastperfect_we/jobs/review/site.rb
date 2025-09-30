# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Site
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__site,
                destination: :review__site
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Site"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__site_archeology_details,
                join_column: :id,
                delete_join_column: false

              transform Ppwe::Transforms::MergeTable,
                source: :prep__site_mapping_options,
                join_column: :id,
                delete_join_column: false
            end
          end
        end
      end
    end
  end
end
