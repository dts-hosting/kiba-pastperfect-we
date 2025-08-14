# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module LoanContactInformation
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: :countryid
            end
          end
        end
      end
    end
  end
end
