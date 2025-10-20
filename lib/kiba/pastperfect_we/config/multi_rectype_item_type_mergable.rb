# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Mixin module encapsulating logic of merging basic record id info and
    #   itemtype for multiple record types into one table, as in
    #   review__image and review__attachment
    module MultiRectypeItemTypeMergable
      # @param type [:image, :attachment]
      def get_merge_config(type)
        {
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
        }.select { |k, v| Kiba::Extend::Job.output?(jobkey_for(k, type)) }
      end

      def get_lookup_file_config(type)
        merge_config.keys
          .map do |t|
          {
            jobkey: jobkey_for(t, type),
            lookup_on: :"#{type}id"
          }
        end.select { |h| Kiba::Extend::Job.output?(h[:jobkey]) }
      end

      def get_itemtype_fields
        merge_config.values
          .map { |h| [h[:fieldmap].keys, h[:constantmap].keys] }
          .flatten
          .select { |f| f.to_s.end_with?("itemtype") }
      end

      def jobkey_for(t, type)
        result = :"prep__#{t}_#{type}"
        return result if Ppwe.job_exists?(result)

        result = :"prep__#{t}_#{type}s"
        return result if Ppwe.job_exists?(result)

        nil
      end
    end
  end
end
