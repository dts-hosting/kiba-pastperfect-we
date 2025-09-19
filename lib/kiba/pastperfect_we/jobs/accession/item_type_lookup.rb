# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Accession
        module ItemTypeLookup
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :preprocess__catalog_item,
                destination: :accession__item_type_lookup
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform FilterRows::FieldPopulated,
                action: :keep,
                field: :accessionid
              transform Delete::FieldsExcept,
                fields: %i[itemtype accessionid]
              transform Deduplicate::Table,
                field: :accessionid,
                compile_uniq_fieldvals: true
            end
          end
        end
      end
    end
  end
end
