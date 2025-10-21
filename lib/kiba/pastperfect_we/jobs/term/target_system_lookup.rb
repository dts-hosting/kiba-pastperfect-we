# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Term
        module TargetSystemLookup
          module_function

          def job(noncirc_source:, circ_source:, dest:)
            sources = [
              noncirc_source, circ_source
            ].select { |src| Ppwe.job_output?(src) }
            return if sources.empty?

            Kiba::Extend::Jobs::Job.new(
              files: {
                source: sources,
                destination: dest
              },
              transformer: get_xforms(sources)
            )
          end

          def get_xforms(sources)
            return single_source_xforms if sources.length == 1

            multi_source_xforms
          end

          def single_source_xforms = nil

          def multi_source_xforms
            Kiba.job_segment do
              transform Deduplicate::Table,
                field: :id,
                compile_uniq_fieldvals: true
              transform Deduplicate::FieldValues,
                fields: Ppwe::Splitting.item_type_field,
                sep: Ppwe.delim
              transform Delete::EmptyFieldValues,
                fields: Ppwe::Splitting.item_type_field,
                delim: Ppwe.delim
              transform Ppwe::Transforms::ReviewTargetFieldMerger
            end
          end
        end
      end
    end
  end
end
