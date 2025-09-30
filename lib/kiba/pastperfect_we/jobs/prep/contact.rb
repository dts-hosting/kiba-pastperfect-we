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
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::AddTermSourceIndication,
                table: "Contact"

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

              transform Ppwe::Transforms::MergeTable,
                source: :prep__flag,
                join_column: :flagid,
                delete_join_column: false,
                merged_field_prefix: "flag"

              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :createdbyuserid,
                fieldmap: {createdby: Ppwe::Terms.table_config["User"]}

              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[spouse spouseid],
                target: :spouse,
                delete_sources: false,
                delim: "#{Ppwe::Terms.term_source_prefix}Contact."

              transform Delete::Fields,
                fields: %i[spouseid createdbyuserid flagid]
            end
          end
        end
      end
    end
  end
end
