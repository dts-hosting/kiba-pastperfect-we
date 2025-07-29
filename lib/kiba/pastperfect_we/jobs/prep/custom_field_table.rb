# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CustomFieldTable
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
              transform Ppwe::Transforms::MergeTable,
                source: :preprocess__field_metadata,
                join_column: :fieldmetadataid,
                drop_fields: %i[objecttype],
                merged_field_prefix: "customfield"

              transform do |row|
                row[:dictionaryid] = nil
                next row unless row[:customfield_fieldtype] == "60"

                row[:dictionaryid] = row[:value]
                row[:value] = nil
                row
              end

              transform Ppwe::Transforms::DictionaryLookup,
                fields: :dictionaryid

              transform CombineValues::FromFieldsWithDelimiter,
                sources: %i[value dictionary],
                target: :customfield_value

              transform Rename::Field,
                from: :dictionary_desc,
                to: :customfield_valuedesc

              transform Delete::Fields,
                fields: :customfield_fieldtype
            end
          end
        end
      end
    end
  end
end
