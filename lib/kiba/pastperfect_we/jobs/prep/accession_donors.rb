# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module AccessionDonors
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :prep__contact
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[groupid]

              transform Merge::MultiRowLookup,
                lookup: prep__contact,
                keycolumn: :contactid,
                fieldmap: {contact: :fullname}

              transform Delete::Fields, fields: :contactid
            end
          end
        end
      end
    end
  end
end
