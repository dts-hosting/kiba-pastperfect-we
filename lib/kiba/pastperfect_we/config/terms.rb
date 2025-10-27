# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Config module for settings and functionality related to term field
    #   identification and term uniqueness
    #
    # "Terms" here means values that get treated as some type of controlled
    #   value in target systems.
    module Terms
      module_function

      extend Dry::Configurable

      # @return [String] value inserted between "term-like value" used in a
      #   record and its Table.Id source indication
      setting :term_source_prefix,
        reader: true,
        default: " termsrc:"

      setting :term_types,
        reader: true,
        default: %i[collection language location misc name place subject]

      # @return [Hash<String => Symbol>] keys are table names; values are the
      #   fields from PREP jobs that contain the "term-like" values merged into
      #   other tables
      setting :table_config,
        reader: true,
        default: {
          "Contact" => :fullname,
          "LexiconItem" => :objectname,
          "Location" => :location,
          "Person" => :fullname,
          "Site" => :sitenumberandname,
          "User" => :fullname
        },
        constructor: ->(default) do
          default.slice(*Ppwe::Table.tablenames)
        end

      setting :skip_use_tables,
        reader: true,
        default: %w[ContactList ContactListRecords DocumentImage]

      setting :itemtype_lookup_config,
        reader: true,
        default: {
          "Accession" => [
            {lkup: :target_system_lookup__accession}
          ],
          "AccessionDonors" => [
            {
              lkup: :preprocess__accession_donors,
              take: :accessionid
            },
            {lkup: :target_system_lookup__accession}
          ],
          "ArchiveContainerLocation" => [
            {
              lkup: :preprocess__archive_container_location,
              take: :catalogitemid
            },
            {lkup: :catalog_item__base}
          ],
          "Attachment" => [
            {lkup: :target_system_lookup__attachment}
          ],
          "CatalogList" => [
            {lkup: :review__catalog_list,
             lookup_on: :id}
          ],
          "Contact" => [
            {lkup: :target_system_lookup__contact}
          ],
          "ContactAttachments" => [
            {
              lkup: :preprocess__contact_attachments,
              take: :attachmentid
            },
            {lkup: :target_system_lookup__attachment}
          ],
          "ContactImage" => [
            {
              lkup: :preprocess__contact_image,
              take: :imageid
            },
            {lkup: :target_system_lookup__image}
          ],
          "ImageObject" => [
            {lkup: :target_system_lookup__image}
          ],
          "LocationHistoryItem" => [
            {
              lkup: :preprocess__location_history_item,
              take: :catalogitemlocationid
            },
            {lkup: :catalog_item__base}
          ],
          "Person" => [
            {lkup: :target_system_lookup__person}
          ],
          "PersonAttachment" => [
            {
              lkup: :preprocess__person_attachment,
              take: :attachmentid
            },
            {lkup: :target_system_lookup__attachment}
          ],
          "PersonImage" => [
            {
              lkup: :preprocess__person_image,
              take: :imageid
            },
            {lkup: :target_system_lookup__image}
          ],
          "Url" => [
            {lkup: :target_system_lookup__url}
          ]
        }

      # @param table [String] table name
      # @return [Hash{String => Array<Reference>}]
      def refs_to_terms_in(table)
        Ppwe::Util::Fk.references_to(table, Ppwe.lookup_column_for(table))
          .reject { |ref| ref.sub }
          .group_by { |ref| ref.table }
      end

      # Fields that do not lookup from other tables and are probably
      #   freetext, but that contain predominantly values that become
      #   terms in target systems
      # @return [Hash] where keys are term_types values
      setting :loose_fields,
        reader: true,
        default: {
          name: [
            {table: "ArchiveIdentity", field: :creatoraddedentry}
          ]
        }

      # Custom fields containing terms. Format is same as for :loose_fields.
      #   Override in client project if they have custom fields.
      # @return [Hash] where keys are term_types values
      setting :custom_fields, reader: true, default: {}

      # @param table [String]
      def uses(table)
        Ppwe::Util::Fk.references_to(table, Ppwe.lookup_column_for(table))
          .reject(&:sub)
      end
    end
  end
end
