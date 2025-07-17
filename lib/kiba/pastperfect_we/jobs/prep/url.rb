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
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              # OLIVIA - We realistically are not going to be migrating/caring
              #   about what user added a URL value to the database. I have put
              #   this here as an example of how you'd do this lookup. Feel free
              #   to remove this, and remove the :prep__user lookup above
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
