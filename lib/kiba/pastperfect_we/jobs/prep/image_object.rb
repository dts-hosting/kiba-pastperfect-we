# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ImageObject
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :prep__user
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[originalobjectformatid equipmenttoacquireid
                  softwaretoacquireid grayscaleorrgbid]

              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :createdbyid,
                fieldmap: {createdby: :fullname}

              transform Delete::Fields,
                fields: :createdbyid

              transform Delete::EmptyFields
            end
          end
        end
      end
    end
  end
end
