# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module SiteMappingOptions
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
              blankness = %i[ispositionbasedongps measure elevation].map do |bf|
                [bf, "0"]
              end.to_h
              transform Delete::EmptyFields,
                consider_blank: blankness

              transform Replace::FieldValueWithStaticMapping,
                source: :ispositionbasedongps,
                mapping: Ppwe.boolean_yes_no_mapping
            end
          end
        end
      end
    end
  end
end
