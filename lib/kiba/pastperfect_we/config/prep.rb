# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Prep
      module_function

      extend Dry::Configurable

      # @param mod [Module] calling this method
      def get_xforms(mod)
        [
          mod.xforms,
          custom_field_merge_xforms(mod.to_s.split("::").last)
        ].compact
      end

      def custom_field_merge_xforms(table)
        return nil unless Ppwe.tables_with_custom_fields.include?(table)

        Kiba.job_segment do
          transform Ppwe::Transforms::CustomFieldMerger,
            parent_table: table
          transform Delete::EmptyFields
        end
      end
    end
  end
end
