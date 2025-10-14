# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Review
        module Attachment
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__attachment,
                destination: :review__attachment,
                lookup: [
                  {
                    jobkey: :prep__catalog_item_attachment,
                    lookup_on: :attachmentid
                  },
                  {
                    jobkey: :prep__accession_attachment,
                    lookup_on: :attachmentid
                  },
                  {
                    jobkey: :prep__exhibit_attachment,
                    lookup_on: :attachmentid
                  },
                  {
                    jobkey: :prep__loan_attachment,
                    lookup_on: :attachmentid
                  },
                  {
                    jobkey: :prep__contact_attachments,
                    lookup_on: :attachmentid
                  },
                  {
                    jobkey: :prep__person_attachment,
                    lookup_on: :attachmentid
                  }
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
                lookup: prep__catalog_item_attachment,
                keycolumn: :id,
                fieldmap: {
                  catalogitemid: :catalogitemid,
                  catalogitemitemid: :itemid,
                  catalogitemitemtype: :itemtype,
                  catalogitemposition: :position
                }
              transform Merge::MultiRowLookup,
                lookup: prep__accession_attachment,
                keycolumn: :id,
                fieldmap: {
                  accessionid: :accessionid,
                  accessionorloannumber: :accessionorloannumber,
                  accessionitemtype: :itemtype
                }
              transform Merge::MultiRowLookup,
                lookup: prep__exhibit_attachment,
                keycolumn: :id,
                fieldmap: {
                  exhibitid: :exhibitid,
                  exhibitname: :exhibitname,
                  exhibititemtype: :itemtype
                }
              transform Merge::MultiRowLookup,
                lookup: prep__loan_attachment,
                keycolumn: :id,
                fieldmap: {
                  loanid: :loanid,
                  loannumberandrecipient: :loannumberandrecipient,
                  loanitemtype: :itemtype
                }
              transform Merge::MultiRowLookup,
                lookup: prep__contact_attachments,
                keycolumn: :id,
                fieldmap: {
                  contactid: :contactid,
                  contactname: :contactname
                },
                constantmap: {
                  contactitemtype: "unmigratable"
                }
              transform Merge::MultiRowLookup,
                lookup: prep__person_attachment,
                keycolumn: :id,
                fieldmap: {
                  personid: :personid,
                  personname: :personname
                },
                constantmap: {
                  personitemtype: "unmigratable"
                }

              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[
                  catalogitemitemtype
                  accessionitemtype
                  exhibititemtype
                  loanitemtype
                  contactitemtype
                  personitemtype
                ],
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
