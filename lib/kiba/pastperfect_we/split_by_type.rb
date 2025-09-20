# frozen_string_literal: true

require "fileutils"

module Kiba
  module PastperfectWe
    # Shared functionality for splitting by type
    module SplitByType
      module_function

      def set_up_target_dirs
        dirpath = Ppwe::Splitting.dir_path
        FileUtils.mkdir_p(dirpath)
        Ppwe::Splitting.targets
          .each do |subdir|
            FileUtils.mkdir_p(File.join(dirpath,
              subdir.to_s))
          end
      end
    end
  end
end
