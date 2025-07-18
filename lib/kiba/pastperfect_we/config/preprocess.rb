# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Preprocess
      module_function

      extend Dry::Configurable

      # @return [Array<Symbol>] fields to be deleted in all tables where they
      #   occur, as part of Preprocess job. Default settings apply to any
      #   PPWE instance. Additional fields in client projects can be added
      #   by including something like the following in the client project
      #   config:
      #   Kiba::PastperfectWe::Preprocess.delete_fields << :fieldtodelete
      setting :delete_fields,
        default: %i[lastmodifiedbyid lastmodifiedbyuserid lastmodifieddate],
        reader: true
    end
  end
end
