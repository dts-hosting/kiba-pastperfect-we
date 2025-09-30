# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Location
        module Prefixed
          module_function

          def job
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: :prep__location,
                destination: :location__prefixed
              },
              transformer: xforms
            )
          end

          def field_name_lookup = @field_name_lookup ||= get_lookup

          def get_lookup
            key = :preprocess__catalog_item_location_fields_names
            return {} unless Kiba::Extend::Job.output?(key)

            reg = Ppwe.registry.resolve(key)
            Kiba::Extend::Utils::Lookup.csv_to_hash(
              file: reg.path, keycolumn: :name
            ).transform_keys { |key| key.downcase.to_sym }
              .transform_values { |val| val.first[:customname] }
          end

          def xforms
            bind = binding

            Kiba.job_segment do
              fields = bind.receiver.field_name_lookup

              transform do |row|
                fields.each do |name, prefix|
                  val = row[name]
                  next if val.blank?

                  row[name] = "#{prefix}: #{val}"
                end
                row
              end

              transform CombineValues::FromFieldsWithDelimiter,
                sources: fields.keys,
                target: :location,
                delete_sources: false,
                delim: " > "

              transform Ppwe::Transforms::AddTermSourceIndication,
                table: "Location"
            end
          end
        end
      end
    end
  end
end
