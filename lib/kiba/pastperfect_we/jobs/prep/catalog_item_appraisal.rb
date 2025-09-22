# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemAppraisal
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
              # sic 'aquisitionvalue'
              transform Delete::FieldValueMatchingRegexp,
                fields: %i[minvalue maxvalue aquisitionvalue],
                match: /^\.000$/
              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: %i[valuedate minvalue maxvalue aquisitionvalue
                  generalappraisalnotes]
            end
          end
        end
      end
    end
  end
end
