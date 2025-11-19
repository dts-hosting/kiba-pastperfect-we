# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Reports
      class NoAssocItems
        def self.call = new.call

        def initialize
          @srcdir = File.join(Ppwe.datadir, "for_review")
          @outpath = File.join(Ppwe.datadir, "reports", "no_assoc_items.csv")
          @acc = {}
        end

        def call
          filepaths.each { |f| extract_info(f) }

        end

        private

        attr_reader :srcdir, :outpath, :acc

        def filepaths = Dir.children(srcdir)
          .map { |f| File.join(srcdir, f) }

        def extract_info(f)
          table = CSV.parse(File.read(f), **Kiba::Extend.csvopts)
          table.by_col!

          vals = table[Ppwe.review_target_field].group_by { |e| e }
          ct = vals["no associated items"]&.length

          acc[f] = ct if ct
        end
      end
    end
  end
end
