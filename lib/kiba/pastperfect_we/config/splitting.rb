# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Config module for settings that eventually need to be extracted
    #   to non-web edition PastPerfect parent code
    module Splitting
      module_function

      extend Dry::Configurable

      # @return [String] path to directory where split files will be written.
      #   Within this directory, a subdirectory will be created for each
      #   split target. The actual split files will be written into the relevant
      #   subdirectories
      setting :dir_path,
        reader: true,
        default: File.join(Ppwe.datadir, "split")

      # @return [Symbol] name of field in which item_type_split_mapping
      #   key values will be found to split on
      setting :item_type_field, reader: true, default: :itemtype

      setting :item_type_mapping,
        reader: true,
        default: {
          "object" => :cspace,
          "photo" => :none,
          "archives" => :aspace,
          "library" => :none,
          "deaccessioned" => :unknown,
          nil => :no_associated_items
        }

      def targets = item_type_mapping.values.uniq

      # @return [Array<Symbol>] split targets that are applied only
      #   if they are the only split target present for a row. That is,
      #   presence of a non-weak split target, prevents the weak
      #   split target from being applied
      setting :weak_targets,
        reader: true,
        default: %i[none no_associated_items unknown]
    end
  end
end
