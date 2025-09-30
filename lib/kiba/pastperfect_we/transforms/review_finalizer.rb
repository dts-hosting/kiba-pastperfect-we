# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Transforms
      # Replaces %-wrapped special characters in all fields
      class ReviewFinalizer
        def initialize
          config = {
            /%QUOT%/ => '"',
            /%TAB%/ => "     ",
            /%CR%/ => "\n",
            /%LF%/ => "\n"
          }
          @replacers = config.map do |find, replace|
            Clean::RegexpFindReplaceFieldVals.new(
              fields: :all,
              find: find,
              replace: replace
            )
          end
        end

        def process(row)
          replacers.each { |r| r.process(row) }
          row
        end

        private

        attr_reader :replacers
      end
    end
  end
end
