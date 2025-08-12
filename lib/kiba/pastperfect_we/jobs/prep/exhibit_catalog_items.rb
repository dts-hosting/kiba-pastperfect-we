# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module ExhibitCatalogItems
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: :prep__catalog_item
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              transform Merge::MultiRowLookup,
                lookup: prep__catalog_item,
                keycolumn: :catalogitemid,
                fieldmap: {catalog_item_itemidnormalized: :itemidnormalized,
                           catalog_item_objectname: :lexicon_item_objectname}

              transform Replace::FieldValueWithStaticMapping,
                source: :onexhibit,
                mapping: Ppwe.boolean_yes_no_mapping
            end
          end
        end
      end
    end
  end
end
