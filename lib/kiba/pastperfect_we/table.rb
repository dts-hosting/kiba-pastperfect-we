# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Table
      module_function

      def data
        @data = tablenames.map do |name|
          [name, {
            origpath: File.join(Ppwe.datadir, "orig", "#{name}.csv"),
            preprocesspath: File.join(Ppwe.datadir, "preprocessed",
              "#{name}.csv"),
            key: key(name)
          }]
        end.to_h
      end

      def filenames
        @filenames ||= Dir.new(File.join(Ppwe.datadir, "orig"))
          .children
          .select { |name| name.end_with?(".csv") }
      end

      def tablenames
        @tablenames ||=
          filenames.map { |name| name.delete_suffix(".csv") } -
          pp_skip_tables -
          Ppwe.client_skip_tables
      end

      def pp_skip_tables
        @pp_skip_tables ||=
          File.readlines(Ppwe.skippable_tables_path, chomp: true)
      end

      def key(name)
        name.underscore
      end
    end
  end
end
