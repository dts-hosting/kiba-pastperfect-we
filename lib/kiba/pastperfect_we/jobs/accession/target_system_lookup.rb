# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Accession
        module TargetSystemLookup
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__accession,
                destination: :accession__target_system_lookup,
                lookup: {jobkey: :prep__catalog_item, lookup_on: :accessionid}
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              transform Delete::FieldsExcept,
                fields: %i[id number accessiontype]
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :id,
                fieldmap: {Ppwe::Splitting.item_type_field =>
                           Ppwe::Splitting.item_type_field}
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: Ppwe.delim
              transform Ppwe::Transforms::ReviewTargetFieldMerger
              transform Delete::Fields, fields: Ppwe::Splitting.item_type_field
            end
          end
        end
      end
    end
  end
end
