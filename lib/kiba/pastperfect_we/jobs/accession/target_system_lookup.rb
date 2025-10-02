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
                source: :prep__catalog_item,
                destination: :accession__target_system_lookup,
                lookup: :prep__accession
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
              transform Ppwe::Transforms::ReviewTargetFieldMerger
              transform Delete::Fields,
                fields: :itemtype
              transform Merge::MultiRowLookup,
                lookup: prep__accession,
                keycolumn: :accessionid,
                fieldmap: {accessionnumber: :number,
                           accessiontype: :accessiontype}
            end
          end
        end
      end
    end
  end
end
