# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Mixin module to organize config settings that need to be set before
    #   loader is set up
    module BaseConfig
      def base_config
        # This is set here for testing. It should be overridden in campus
        #   project config
        setting :datadir,
          default: File.join(Bundler.root, "data"),
          reader: true

        # Working directory - setting used in campus projects to control
        #   pre-job tasks
        setting :wrkdir,
          default: File.join(datadir, "working"),
          reader: true

        # @return [String] path to list of skippable table names for any
        #   PP WE project
        setting :skippable_tables_path,
          default: nil,
          reader: true,
          constructor: ->(default) do
            File.join(
              Gem.loaded_specs["pastperfect_we"].full_gem_path,
              "data", "skippable_tables.txt"
            )
          end

        # @return [Array<String>] table names to be skipped for individual
        #   client project
        setting :client_skip_tables, default: [], reader: true

        # @return [Hash{String=>Symbol}] keys are original PP table names or
        #   constant values derived from them; values are the default field
        #   from each table that should be used as :lookup_on value in
        #   registry entries for jobs
        setting :lookup_ids,
          default: {
            "AccessionActivities" => :accessionid,
            "AccessionAttachment" => :accessionid,
            "AccessionCustomField" => :accessionid,
            "AccessionDonors" => :accessionid,
            "CatalogItemCustomField" => :catalogitemid,
            "CatalogItemLexicon" => :catalogitemid,
            "ConditionReportCleanlinessState" => :reportid,
            "ConditionReportImage" => :conditionreportid,
            "ConditionReportMaterialsCondition" => :reportid,
            "ConditionReportPartsCondition" => :reportid,
            "ConditionReportStructureCondition" => :reportid,
            "ConditionReportSurfaceCondition" => :reportid,
            "ContactActivities" => :contactid,
            "ContactAddressAndPhoneNumbers" => :contactid,
            "ContactAttachments" => :contactid,
            "ContactBiographicalInfo" => :contactid,
            "ContactCustomField" => :contactid,
            "ContactListRecords" => :contactid,
            "ContactUrls" => :contactid,
            "ContactVolunteerInfo" => :contactid,
            "ExhibitAttachment" => :exhibitid,
            "ExhibitCatalogItems" => :exhibitid,
            "ExhibitClimateControl" => :exhibitid,
            "ExhibitImage" => :exhibitid,
            "ExhibitInsuranceInformation" => :exhibitid,
            "ExhibitSecurity" => :exhibitid,
            "ExhibitShippingInformation" => :exhibitid,
            "ExhibitUrl" => :exhibitid,
            "ExhibitVisitorTraffic" => :exhibitid,
            "InKindGift" => :receivedfromid,
            "PersonAttachment" => :personid,
            "PersonUrl" => :personid,
            "SiteCustomField" => :siteid,
            "User" => :userid
          },
          reader: true

        setting :boolean_yes_no_mapping,
          default: {"0" => "no", "1" => "yes"},
          reader: true

        # @return [Array<String>] names of tables that get custom
        #   fields merged into them. The default value includes all
        #   such tables known for PPWE. When this setting is called,
        #   the constructor removes those where there isn't a
        #   corresponding CustomField table for the client.
        setting :tables_with_custom_fields,
          default: %w[Accession CatalogItem Contact Person Site],
          reader: true,
          constructor: ->(default) do
            default.select do |base|
              Ppwe::Table.tablenames.include?("#{base}CustomField")
            end
          end
        # ----------------------------------------------------------------
        # REQUIRED SETTINGS - Must be defined/overridden in client project
        #   config
        # ----------------------------------------------------------------
        # @return [:dev, :prod]
        # Controls selected behavior of migration. Generally :dev will retain
        #   some data values that will be removed when this is set to :prod.
        #
        # - Names marked by client to be dropped from migration: When `dev`,
        #   these will be retained, but converted to `DROPPED FROM MIGRATION`
        #   so that any inadvertent effects of dropping the names may be
        #   caught. When `prod`, the names just won't be merged into any data
        # - If there are any supplied jobs registered by
        #   `RegistryData.register_sample_files`, the sample will be selected
        #   in the final `for_ingest` job for each target record type
        # - Some prep jobs will retain otherwise deleted rows if the status is
        #   :prelim. Can be used to create initial reports for decisions about
        #   migrating inactive values or not
        setting :migration_status, default: :dev, reader: true

        # ----------------------------------------------------------------
        # Settings that usually can be left as-is, but may be overridden in
        #   client project config if needed
        # ----------------------------------------------------------------
        # @return [String] value used to join multiple notes when the target
        #   note field is single-valued
        setting :notedelim, default: "%CR%%CR%", reader: true

        # @return [String] value inserted to flag unexpected or unhandled
        #   values when running jobs with :migration_status == :dev
        setting :check_value, default: "CHECK ME", reader: true

        # ----------------------------------------------------------------
        # Inherit from Kiba::Extend, but namespace for local use
        # ----------------------------------------------------------------
        # @return [String]
        # Default delimiter for splitting/joining values in multi-valued
        #   fields.
        setting :delim, default: Kiba::Extend.delim, reader: true

        # Default subgrouping delimiter for splitting/joining values in
        #   multi-valued fields
        # @return [String]
        setting :sgdelim, default: Kiba::Extend.sgdelim, reader: true

        # Default string to be treated as though it were a null/empty value.
        # @return [String]
        setting :nullvalue, default: Kiba::Extend.nullvalue, reader: true
      end
    end
  end
end
