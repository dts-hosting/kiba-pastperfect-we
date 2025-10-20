# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module TargetSystemLookup
        module Accession
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__accession,
                destination: :target_system_lookup__accession,
                lookup: {jobkey: :prep__catalog_item, lookup_on: :accessionid}
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id number accessiontype loannumber]
              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[number loannumber],
                target: :number,
                delete_sources: true,
                delim: "; "

              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :id,
                fieldmap: {Ppwe::Splitting.item_type_field =>
                           Ppwe::Splitting.item_type_field}
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: Ppwe.delim
              transform Ppwe::Transforms::ReviewTargetFieldMerger
            end
          end
        end
      end
    end
  end
end
