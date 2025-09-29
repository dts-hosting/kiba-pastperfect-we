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
    end
  end
end
