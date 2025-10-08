# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module IncomingLoanReturnedItems
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: get_lookups
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def get_lookups
            return [] if Ppwe.mode == :migration

            {jobkey: :prep__accession, lookup_on: :id}
          end

          def xforms
            Kiba.job_segment do
              transform Replace::FieldValueWithStaticMapping,
                source: :isreturned,
                mapping: Ppwe.boolean_yes_no_mapping

              if Ppwe.mode == :review
                transform Merge::MultiRowLookup,
                  lookup: prep__accession,
                  keycolumn: :accessionid,
                  fieldmap: {
                    accessionnumber: :number,
                    loannumber: :loannumber
                  }
              end
            end
          end
        end
      end
    end
  end
end
