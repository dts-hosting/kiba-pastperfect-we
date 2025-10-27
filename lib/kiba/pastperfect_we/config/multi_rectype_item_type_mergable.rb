# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Mixin module encapsulating logic of merging basic record id info and
    #   itemtype for multiple record types into one table, as in
    #   review__image and review__attachment
    module MultiRectypeItemTypeMergable
      AUTHORITY_MERGE_TABLES = %i[contact person site]

      UNMIGRATABLE_TYPES_FOR_AUTH = %i[attachment image]

      # Mapping of fields to set as :lookup_on value in lookup_file_config
      LOOKUP_ON_MAP = {
        attachment: :attachmentid,
        image: :imageid,
        url: :id
      }

      # Types for which a position value is included in merge_config fieldmap
      POSITIONED_TYPES = [:image]

      # @param type [:image, :attachment]
      def get_merge_config(type)
        {
          accession: {
            fieldmap: {
              accessionid: :accessionid,
              accessionorloannumber: :accessionorloannumber
            }
          },
          catalog_item: {
            fieldmap: {
              catalogitemid: :catalogitemid,
              catalogitemitemid: :itemid
            }
          },
          condition_report: {
            fieldmap: {
              conditionreportid: :catalogitemid,
              conditionreportitemid: :itemid
            }
          },
          contact: {
            fieldmap: {
              contactid: :contactid,
              contactname: :contactname
            }
          },
          exhibit: {
            fieldmap: {
              exhibitid: :exhibitid,
              exhibitname: :exhibitname
            }
          },
          loan: {
            fieldmap: {
              loanid: :loanid,
              loannumberandrecipient: :loannumberandrecipient
            }
          },
          person: {
            fieldmap: {
              personid: :personid,
              personname: :personname
            }
          },
          site: {
            fieldmap: {
              siteid: :siteid,
              sitename: :sitename
            }
          }
        }.select { |k, v| Kiba::Extend::Job.output?(jobkey_for(k, type)) }
          .each do |k, v|
            handle_position(k, v, type)
            handle_itemtype(k, v, type)
          end
      end

      def lookup_on(type)
        raise "Add :#{type} to LOOKUP_ON_MAP" unless LOOKUP_ON_MAP.key?(type)

        LOOKUP_ON_MAP[type]
      end

      def handle_position(k, v, type)
        return unless POSITIONED_TYPES.include?(type)

        posfield = "#{k}position".delete("_").to_sym
        v[:fieldmap][posfield] = :position
      end

      def handle_itemtype(k, v, type)
        targetfield = "#{k}itemtype".delete("_").to_sym
        if unmigratable?(k, type)
          v[:constantmap] = {targetfield => "unmigratable"}
        else
          v[:constantmap] = {}
          v[:fieldmap][targetfield] = Ppwe::Splitting.item_type_field
        end
      end

      def get_lookup_file_config(type)
        merge_config.keys
          .map do |t|
            {
              jobkey: jobkey_for(t, type),
              lookup_on: lookup_on(type)
            }
          end.select { |h| Kiba::Extend::Job.output?(h[:jobkey]) }
      end

      def get_itemtype_fields
        merge_config.values
          .map { |h| [h[:fieldmap].keys, h[:constantmap]&.keys] }
          .flatten
          .compact
          .select { |f| f.to_s.end_with?("itemtype") }
      end

      def jobkey_for(t, type)
        result = :"prep__#{t}_#{type}"
        return result if Ppwe.job_exists?(result)

        result = :"prep__#{t}_#{type}s"
        return result if Ppwe.job_exists?(result)

        nil
      end

      def unmigratable?(table, type) = AUTHORITY_MERGE_TABLES.include?(table) &&
        UNMIGRATABLE_TYPES_FOR_AUTH.include?(type)
    end
  end
end
