# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemLexicon
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

            [:prep__lexicon_item]
          end

          def xforms
            Kiba.job_segment do
              if Ppwe.mode == :review
                lookup_fields = %i[itemname2id itemname3id]

                lookup_fields.each do |field|
                  target = field.to_s
                    .sub("item", "object")
                    .delete_suffix("id")
                    .to_sym
                  transform Merge::MultiRowLookup,
                    lookup: prep__lexicon_item,
                    keycolumn: field,
                    fieldmap: {target => :objectname}
                end
                transform Delete::Fields,
                  fields: lookup_fields
              end
            end
          end
        end
      end
    end
  end
end
