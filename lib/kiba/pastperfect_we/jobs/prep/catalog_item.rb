# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItem
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

            %i[prep__accession
              prep__lexicon_item
              prep__user]
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[disposalmethodid statusid collectionid othernameid
                  deaccessionauthorizedbyuserid catalogedbyid]

              transform Clean::RegexpFindReplaceFieldVals,
                fields: %i[yearrangefrom yearrangeto
                  numberofcatalogitemattachments
                  numberofcatalogitemimages],
                find: /^0$/,
                replace: ""

              %i[isremoved isdefault deaccessioned ispublicaccess itemonloan
                isitemonexhibit].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              if Ppwe.mode == :review
                transform Replace::FieldValueWithStaticMapping,
                  source: :itemtype,
                  mapping: Ppwe::Enums.item_type,
                  fallback_val: nil

                transform Ppwe::Transforms::ReviewTargetFieldMerger

                transform Merge::MultiRowLookup,
                  lookup: prep__accession,
                  keycolumn: :accessionid,
                  fieldmap: {
                    accessionnumber: :number,
                    incomingloannumber: :loannumber,
                    accessiontype: :accessiontype
                  }

                transform Merge::MultiRowLookup,
                  lookup: prep__user,
                  keycolumn: :createdbyuserid,
                  fieldmap: {createdby: Ppwe::Terms.table_config["User"]}

                transform Merge::MultiRowLookup,
                  lookup: prep__user,
                  keycolumn: :statusbyuserid,
                  fieldmap: {statusby: Ppwe::Terms.table_config["User"]}

                transform Merge::MultiRowLookup,
                  lookup: prep__lexicon_item,
                  keycolumn: :itemnameid,
                  fieldmap: {objectname: :objectname}
                transform Rename::Field, from: :itemnameid, to: :lexiconitemid

                transform Delete::Fields,
                  fields: %i[statusbyuserid createdbyuserid]
              end
            end
          end
        end
      end
    end
  end
end
