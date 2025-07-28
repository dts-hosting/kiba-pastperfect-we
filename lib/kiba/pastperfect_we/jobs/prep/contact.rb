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
                lookup: %i[
                  preprocess__contact
                  prep__user
                ]
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
              end

              transform Merge::MultiRowLookup,
                lookup: preprocess__contact,
                keycolumn: :spouseid,
                fieldmap: {spouse: :fullname}

              transform Delete::Fields, fields: :spouseid

              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :createdbyuserid,
                fieldmap: {createdby: :fullname}

              transform Delete::Fields, fields: :createdbyuserid
            end
          end
        end
      end
    end
  end
end
