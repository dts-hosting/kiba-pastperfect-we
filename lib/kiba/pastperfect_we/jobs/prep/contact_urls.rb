# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ContactUrls
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :target_system_lookup__contact
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
              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__contact,
                keycolumn: :contactid,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                }
              transform Rename::Field,
                from: :url_url,
                to: :url
            end
          end
        end
      end
    end
  end
end
