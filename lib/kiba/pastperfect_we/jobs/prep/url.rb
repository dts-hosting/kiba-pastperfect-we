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
                lookup: get_lookups
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def get_lookups
            return [] if Ppwe.mode == :migration

            [:prep__user]
          end

          def xforms
            Kiba.job_segment do
              transform Replace::FieldValueWithStaticMapping,
                source: :ispublicaccess,
                mapping: Ppwe.boolean_yes_no_mapping

              if Ppwe.mode == :review
                transform Merge::MultiRowLookup,
                  lookup: prep__user,
                  keycolumn: :useraddedid,
                  fieldmap: {useradded: :fullname}

                transform Delete::Fields,
                  fields: %i[useraddedid]
              end

              transform Rename::Fields, fieldmap: {
                name: :url,
                useradded: :addedby
              }
            end
          end
        end
      end
    end
  end
end
