# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemUrl
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::MergeTable,
                source: :prep__url,
                join_column: :urlid,
                merged_field_prefix: "url"

              transform Rename::Field,
                from: :url_url,
                to: :url

              transform Ppwe::Transforms::MergeTable,
                source: :catalog_item__base,
                join_column: :catalogitemid,
                delete_join_column: false
            end
          end
        end
      end
    end
  end
end
