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
                lookup: %i[
                  prep__user
                  prep__accession
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[disposalmethodid statusid collectionid othernameid
                  deaccessionauthorizedbyuserid catalogedbyid]

              %i[isremoved isdefault deaccessioned ispublicaccess itemonloan
                isitemonexhibit].each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              transform Merge::MultiRowLookup,
                lookup: prep__accession,
                keycolumn: :accessionid,
                fieldmap: {accession_title: :title}

              transform Ppwe::Transforms::MergeTable,
                source: :prep__lexicon_item,
                join_column: :itemnameid,
                merged_field_prefix: "lexicon_item"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__flag,
                join_column: :flagid,
                delete_join_column: false,
                merged_field_prefix: "flag"

              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :createdbyuserid,
                fieldmap: {createdby: :fullname}

              transform Merge::MultiRowLookup,
                lookup: prep__user,
                keycolumn: :statusbyuserid,
                fieldmap: {statusby: :fullname}

              transform Delete::Fields,
                fields: %i[statusbyuserid createdbyuserid flagid]
            end
          end
        end
      end
    end
  end
end
