# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Image
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__image_object,
                destination: :review__image,
                lookup: [
                  {jobkey: :prep__catalog_item_image, lookup_on: :imageid},
                  {jobkey: :prep__condition_report_image, lookup_on: :imageid},
                  {jobkey: :prep__exhibit_image, lookup_on: :imageid},
                  {jobkey: :prep__contact_image, lookup_on: :imageid},
                  {jobkey: :prep__person_image, lookup_on: :imageid}
                ]
              },
              transformer: [xforms, Ppwe::Review.final_xforms].compact
            )
          end

          def init_headers
            hdrs = %i[id]
            hdrs << Ppwe::Splitting.item_type_field
            hdrs << Ppwe.review_target_field
            hdrs
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item_image,
                keycolumn: :id,
                fieldmap: {
                  catalogitemid: :catalogitemid,
                  catalogitemitemid: :itemid,
                  catalogitemitemtype: :itemtype,
                  catalogitemposition: :position
                }

              transform Merge::MultiRowLookup,
                lookup: prep__condition_report_image,
                keycolumn: :id,
                fieldmap: {
                  conditionreportid: :catalogitemid,
                  conditionreportitemid: :itemid,
                  conditionreportitemtype: :itemtype,
                  conditionreportposition: :position
                }

              transform Merge::MultiRowLookup,
                lookup: prep__exhibit_image,
                keycolumn: :id,
                fieldmap: {
                  exhibitid: :exhibitid,
                  exhibitname: :exhibitname,
                  exhibititemtype: :itemtype,
                  exhibitposition: :position
                }

              transform Merge::MultiRowLookup,
                lookup: prep__contact_image,
                keycolumn: :id,
                fieldmap: {
                  contactid: :contactid,
                  contactname: :contactname,
                  contactposition: :position
                },
                constantmap: {
                  contactitemtype: "unmigratable"
                }

              transform Merge::MultiRowLookup,
                lookup: prep__person_image,
                keycolumn: :id,
                fieldmap: {
                  personid: :personid,
                  personname: :personname,
                  personposition: :position
                },
                constantmap: {
                  personitemtype: "unmigratable"
                }

              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[catalogitemitemtype
                  conditionreportitemtype
                  exhibititemtype
                  contactitemtype
                  personitemtype],
                target: Ppwe::Splitting.item_type_field,
                delete_sources: false,
                delim: Ppwe.delim
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: "|"
              transform Ppwe::Transforms::ReviewTargetFieldMerger
            end
          end
        end
      end
    end
  end
end
