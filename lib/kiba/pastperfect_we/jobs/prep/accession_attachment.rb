# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module AccessionAttachment
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :target_system_lookup__accession
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: target_system_lookup__accession,
                keycolumn: :accessionid,
                fieldmap: {
                  :accessiontype => :accessiontype,
                  :accessionorloannumber => :number,
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field,
                  Ppwe.review_target_field => Ppwe.review_target_field
                }
            end
          end
        end
      end
    end
  end
end
