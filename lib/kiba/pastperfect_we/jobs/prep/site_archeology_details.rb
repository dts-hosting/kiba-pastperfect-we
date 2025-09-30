# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module SiteArcheologyDetails
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
              boolean_fields = %i[isassociatedarchives islevelbags islithics
                isshellfish iswovenorganics isceramics issedimentsamples
                isunmodifiedbone ischarcoal ismetal ishistorics
                isflotationsamples ismodifiedbone isorganics isglass]
              blankness = boolean_fields.map { |bf| [bf, "0"] }
                .to_h
              transform Delete::EmptyFields,
                consider_blank: blankness

              boolean_fields.each do |field|
                transform Replace::FieldValueWithStaticMapping,
                  source: field,
                  mapping: Ppwe.boolean_yes_no_mapping
              end

              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[projectnameid projecttypeid investigatoraffiliationid
                  electroniccatalogstatusid rehousingstatusid
                  controllingagencyid]
            end
          end
        end
      end
    end
  end
end
