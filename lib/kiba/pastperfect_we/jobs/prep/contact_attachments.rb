# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ContactAttachments
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :prep__contact
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__contact,
                keycolumn: :contactid,
                fieldmap: {contactname: Ppwe::Terms.table_config["Contact"]}
            end
          end
        end
      end
    end
  end
end
