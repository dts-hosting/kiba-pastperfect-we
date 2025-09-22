# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Jobs
      module Prep
        module CatalogItemPhoto
          module_function

          def job(source:, dest:)
            Kiba::Extend::Jobs::Job.new(
              files: {
                source: source,
                destination: dest,
                lookup: %i[
                  prep__person
                  prep__site
                ]
              },
              transformer: Ppwe::Prep.get_xforms(self)
            )
          end

          def xforms
            Kiba.job_segment do
              orig_hdrs = Ppwe.headers_for(:preprocess__catalog_item_photo) -
                [:catalogitemid]
              transform FilterRows::AnyFieldsPopulated,
                action: :keep,
                fields: orig_hdrs

              transform Ppwe::Transforms::DictionaryLookup,
                fields: %i[studioid processingmethodid printsizeid filmsizeid
                  originalcopyid eventid negativelocationid]

              transform Merge::MultiRowLookup,
                lookup: prep__person,
                keycolumn: :photographerid,
                fieldmap: {photographer: :fullname}

              transform Merge::MultiRowLookup,
                lookup: prep__site,
                keycolumn: :siteid,
                fieldmap: {sitename: :sitename}
              transform Delete::Fields,
                fields: %i[photographerid siteid]
            end
          end
        end
      end
    end
  end
end
