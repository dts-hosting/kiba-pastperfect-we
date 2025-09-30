# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Terms
      module_function

      extend Dry::Configurable

      # @return [String] value inserted between "term-like value" used in a
      #   record and its Table.Id source indication
      setting :term_source_prefix,
        reader: true,
        default: " termsrc:"

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
    end
  end
end
