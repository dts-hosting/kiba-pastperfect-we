# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ExhibitSecurity
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              # This little complication keeps us from being warned that we
              #   can't rename fields that don't exist after preprocessing has
              #   been done
              needs_prefix = %i[staffrequired restrictions notes]
              to_prefix = needs_prefix.intersection(
                Ppwe.mergeable_headers_for(:preprocess__exhibit_security)
              )

              to_prefix.each do |field|
                transform Rename::Field,
                  from: field,
                  to: :"security#{field}"
              end
            end
          end
        end
      end
    end
  end
end
