# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module Contact
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :preprocess__contact
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[groupid]

              %i[isdocent isemployee isstudent isvolunteer isremoved
                isalist isblist iscollectiondonor].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping

                transform Merge::MultiRowLookup,
                  lookup: preprocess__contact,
                  keycolumn: :spouseid,
                  fieldmap: {spouse: :fullname}
                transform Delete::Fields, fields: :spouseid
              end
            end
          end
        end
      end
    end
  end
end
