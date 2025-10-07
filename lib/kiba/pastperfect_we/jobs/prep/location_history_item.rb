# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LocationHistoryItem
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

            %i[
              location__prefixed
              prep__user
            ]
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[moveauthorizedbyid movedbyid]

              transform Replace::FieldValueWithStaticMapping,
                source: :isremoved,
                mapping: Ppwe.boolean_yes_no_mapping

              if Ppwe.mode == :review
                transform Merge::MultiRowLookup,
                  lookup: location__prefixed,
                  keycolumn: :locationid,
                  fieldmap: {location: Ppwe::Terms.table_config["Location"]}
                transform Merge::MultiRowLookup,
                  lookup: prep__user,
                  keycolumn: :actionbyid,
                  fieldmap: {actionby: Ppwe::Terms.table_config["User"]}

                transform Delete::Fields,
                  fields: %i[locationid actionbyid]
              end

              transform Rename::Field,
                from: :catalogitemlocationid,
                to: :catalogitemid
            end
          end
        end
      end
    end
  end
end
