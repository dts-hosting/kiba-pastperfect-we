# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Term
        module ItemtypeCirc
          module_function

          def job(source:, dest:, lookup:)
            return unless Ppwe.job_output?(source)

            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: lookup
              },
              transformer: xforms(lookup)
            )
          end

          def xforms(lookup)
            Kiba.job_segment do
              transform FilterRows::FieldEqualTo,
                action: :keep,
                field: :circular,
                value: "true"
              transform Merge::MultiRowLookup,
                lookup: send(lookup),
                keycolumn: :referringid,
                fieldmap: {
                  Ppwe::Splitting.item_type_field =>
                    Ppwe::Splitting.item_type_field
                }
              transform Delete::EmptyFieldValues,
                fields: Ppwe::Splitting.item_type_field,
                delim: Ppwe.delim
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
              transform Rename::Fields, fieldmap: {
                termid: :id
              }
            end
          end
        end
      end
    end
  end
end
