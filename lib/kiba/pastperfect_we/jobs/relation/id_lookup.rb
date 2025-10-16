# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Relation
        module IdLookup
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :preprocess__catalog_item_relation,
                destination: :relation__id_lookup
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: :relationid
              transform FilterRows::FieldPopulated,
                action: :keep,
                field: :relationid
              transform Deduplicate::Table,
                field: :relationid
              transform Rename::Field,
                from: :relationid,
                to: :uuid
              transform Merge::IncrementingField, target: :id
            end
          end
        end
      end
    end
  end
end
