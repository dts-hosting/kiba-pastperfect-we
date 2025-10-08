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

              %i[isrestricted ispublic].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :createdbyid,
                fieldmap: {createdby: Ppwe::Terms.table_config["User"]}

              transform Delete::Fields,
                fields: %i[createdbyid extralargeimagefileobjectid
                  miniaturesquarefileobjectid
                  miniaturenativefileobjectid
                  smallimagefileobjectid
                  mediumimagefileobjectid
                  largeimagefileobjectid]
              transform Clean::RegexpFindReplaceFieldVals,
                fields: :azimuth,
                find: /^0$/,
                replace: ""

              transform Ppwe::Transforms::MergeTable,
                source: :prep__file_object,
                join_column: :originalfileobjectid,
                drop_fields: %i[museumid],
                merged_field_prefix: "original"
            end
          end
        end
      end
    end
  end
end
