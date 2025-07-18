# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module FileObject
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[museumid]
            end
          end
        end
      end
    end
  end
end
