# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ContactList
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
              transform Ppwe::Transforms::DictionaryLookup,
                fields: :listcategoryid

              %i[isprivate islocked isremoved].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :listmanagerid,
                fieldmap: {listmanager: :fullname}

              transform Delete::Fields,
                fields: :listmanagerid

              transform Delete::EmptyFields
            end
          end
        end
      end
    end
  end
end
