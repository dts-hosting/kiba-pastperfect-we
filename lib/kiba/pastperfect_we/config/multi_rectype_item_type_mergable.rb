# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Mixin module encapsulating logic of merging basic record id info and
    #   itemtype for multiple record types into one table, as in
    #   review__image and review__attachment
    module MultiRectypeItemTypeMergable
      def positioned_types = [:image]

      # @param type [:image, :attachment]
      def get_merge_config(type)
        result = {
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
              accessionitemtype: :itemtype,
              accessionposition: :position
            },
            constantmap: {}
          },
          condition_report: {
            fieldmap: {
              conditionreportid: :catalogitemid,
              conditionreportitemid: :itemid,
              conditionreportitemtype: :itemtype,
              conditionreportposition: :position
            },
            constantmap: {}
          },
          exhibit: {
            fieldmap: {
              exhibitid: :exhibitid,
              exhibitname: :exhibitname,
              exhibititemtype: :itemtype,
              exhibitposition: :position
            },
            constantmap: {}
          },
          loan: {
            fieldmap: {
              loanid: :loanid,
              loannumberandrecipient: :loannumberandrecipient,
              loanitemtype: :itemtype,
              loanposition: :position
            },
            constantmap: {}
          },
          contact: {
            fieldmap: {
              contactid: :contactid,
              contactname: :contactname,
              contactposition: :position
            },
            constantmap: {
              contactitemtype: "unmigratable"
            }
          },
          person: {
            fieldmap: {
              personid: :personid,
              personname: :personname,
              personposition: :position
            },
            constantmap: {
              personitemtype: "unmigratable"
            }
          }
        }.select { |k, v| Kiba::Extend::Job.output?(jobkey_for(k, type)) }
        return result if positioned_types.include?(type)

        result.transform_values do |hash|
          hash[:fieldmap].delete_if { |_k, v| v == :position }
          hash
        end
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
