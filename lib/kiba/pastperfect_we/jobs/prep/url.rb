# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module Url
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
              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :useraddedid,
                fieldmap: {useradded: :fullname}

              transform Delete::Fields,
                fields: %i[dateadded useraddedid]

              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[]

              transform Replace::FieldValueWithStaticMapping,
                source: :ispublicaccess,
                mapping: Ppwe.boolean_yes_no_mapping
            end
          end
        end
      end
    end
  end
end
