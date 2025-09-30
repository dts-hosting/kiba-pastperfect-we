# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Contact
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__contact,
                destination: :contact__combined,
                lookup: %i[
                  prep__contact_urls
                  prep__contact_attachments
                ]
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Contact"
              transform Ppwe::Transforms::DeleteTermSourceIndication,
                table: "Contact",
                term_src: :spouse

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_biographical_info,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_address_and_phone_numbers,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_list_records,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_volunteer_info,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id,
                merged_field_prefix: "volunteer_info"

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_attachments,
                join_column: :id,
                delete_join_column: false,
                drop_fields: :id,
                merged_field_prefix: "attachment"

              transform Count::MatchingRowsInLookup,
                lookup: prep__contact_attachments,
                keycolumn: :id,
                targetfield: :attachment_count

              transform Ppwe::Transforms::MergeTable,
                source: :prep__contact_urls,
                join_column: :id,
                delete_join_column: false,
                drop_fields: %i[id url_useradded]
            end
          end
        end
      end
    end
  end
end
