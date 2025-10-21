# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Term
        module ItemtypeNoncirc
          module_function

          def job(source:, dest:)
            return unless Ppwe.job_output?(source)

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
              transform FilterRows::FieldEqualTo,
                action: :reject,
                field: :circular,
                value: "true"
              transform Ppwe::Transforms::TermUseItemTypeAssigner
              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[referringtable referringid
                  referringtablelookupfield],
                target: :usedin,
                delim: "."
              transform Delete::Fields,
                fields: %i[termtable circular]

              transform Deduplicate::Table,
                field: :termid,
                compile_uniq_fieldvals: true
              transform Deduplicate::FieldValues,
                fields: :referringitemtype,
                sep: Ppwe.delim
              transform Delete::EmptyFieldValues,
                fields: :referringitemtype,
                delim: Ppwe.delim
              transform Rename::Fields, fieldmap: {
                termid: :id,
                referringitemtype: Ppwe::Splitting.item_type_field
              }
            end
          end
        end
      end
    end
  end
end
