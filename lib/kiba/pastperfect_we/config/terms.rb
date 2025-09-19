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
        default: %i[location misc name place subject]

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
        }

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
    end
  end
end
