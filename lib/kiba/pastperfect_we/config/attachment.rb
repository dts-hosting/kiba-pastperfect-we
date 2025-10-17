# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Config module for settings and functionality related to the Attachment
    #   table and known child/auxiliary tables such as ExhibitAttachment and
    #   CatalogItemAttachment
    module Attachment
      module_function

      extend Dry::Configurable

      setting :merge_config,
        reader: true,
        default: {
          catalog_item: {
            fieldmap: {
              catalogitemid: :catalogitemid,
              catalogitemitemid: :itemid,
              catalogitemitemtype: :itemtype,
              catalogitemposition: :position
            },
            constantmap: {}
          },
          accession: {
            fieldmap: {
              accessionid: :accessionid,
              accessionorloannumber: :accessionorloannumber,
              accessionitemtype: :itemtype
            },
            constantmap: {}
          },
          exhibit: {
            fieldmap: {
              exhibitid: :exhibitid,
              exhibitname: :exhibitname,
              exhibititemtype: :itemtype
            },
            constantmap: {}
          },
          loan: {
            fieldmap: {
              loanid: :loanid,
              loannumberandrecipient: :loannumberandrecipient,
              loanitemtype: :itemtype
            },
            constantmap: {}
          },
          contact: {
            fieldmap: {
              contactid: :contactid,
              contactname: :contactname
            },
            constantmap: {
              contactitemtype: "unmigratable"
            }
          },
          person: {
            fieldmap: {
              personid: :personid,
              personname: :personname
            },
            constantmap: {
              personitemtype: "unmigratable"
            }
          }
        },
        constructor: ->(default) do
          default.select { |k, v| Kiba::Extend::Job.output?(jobkey_for(k)) }
        end

      setting :lookup_file_config,
        reader: true,
        default: [],
        constructor: ->(default) do
          merge_config.keys
            .map { |t| {jobkey: jobkey_for(t), lookup_on: :attachmentid} }
            .select { |h| Kiba::Extend::Job.output?(h[:jobkey]) }
        end

      setting :itemtype_fields,
        reader: true,
        default: [],
        constructor: ->(default) do
          merge_config.values
            .map { |h| [h[:fieldmap].keys, h[:constantmap].keys] }
            .flatten
            .select { |f| f.to_s.end_with?("itemtype") }
        end

      def jobkey_for(t)
        result = :"prep__#{t}_attachment"
        return result if Ppwe.job_exists?(result)

        result = :"prep__#{t}_attachments"
        return result if Ppwe.job_exists?(result)

        nil
      end
    end
  end
end
