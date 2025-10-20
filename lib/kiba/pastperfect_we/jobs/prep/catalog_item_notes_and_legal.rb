# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemNotesAndLegal
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              if Ppwe.mode == :review
                transform Replace::FieldValueWithStaticMapping,
                  source: :webright,
                  mapping: Ppwe::Enums.web_right
              end
            end
          end
        end
      end
    end
  end
end
