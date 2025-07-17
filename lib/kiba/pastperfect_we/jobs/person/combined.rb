# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Person
        module Combined
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__person,
                destination: :person__combined,
                lookup: :prep__person_url
              },
              transformer: xforms
            )
          end

          def xforms
            Kiba.job_segment do
              # OLIVIA
              # This job definition clearly shows the distinction I was trying
              #   to make in our meeting today about MergeTable (for merging in
              #   all or most of a table) vs. Merge::MultiRowLookup (for merging
              #   in just a few fields)
              transform Ppwe::Transforms::MergeTable,
                source: :prep__person_biographical_information,
                join_column: :id,
                drop_fields: %i[maritalstatus],
                opts: {null_placeholder: "FOO",
                       constantmap: {biomerged: "y"}}

              transform Merge::MultiRowLookup,
                lookup: prep__person_url,
                keycolumn: :id,
                fieldmap: {
                  url: :url_name,
                  url_display: :url_displayname
                }
            end
          end
        end
      end
    end
  end
end
