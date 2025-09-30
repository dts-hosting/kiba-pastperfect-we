# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Settings related to preparing final jobs in review mode
    module Review
      module_function

      extend Dry::Configurable

      # @return [nil, Proc] Kiba.job_segment logic to be run
      #   at end of review jobs
      setting :final_xforms,
        reader: true,
        default: nil,
        constructor: ->(default) do
          Kiba.job_segment do
            transform Ppwe::Transforms::ReviewFinalizer
          end
        end
    end
  end
end
