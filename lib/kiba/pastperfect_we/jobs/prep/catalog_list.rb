# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogList
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

            %i[prep__user]
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[listcategoryid]

              %i[isprivate islocked isremoved].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              if Ppwe.mode == :review
                transform Merge::MultiRowLookup,
                  lookup: prep__user,
                  keycolumn: :listmanagerid,
                  fieldmap: {listmanager: Ppwe::Terms.table_config["User"]}
                transform Delete::Fields,
                  fields: %i[listmanagerid]
              end
            end
          end
        end
      end
    end
  end
end
