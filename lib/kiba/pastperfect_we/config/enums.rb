# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Mappings of numeric enum values stored in the database to human-usable
    #   values. We HOPE these are going to be the same across the board, for
    #   all PPWE instance. If not, we got problems... 🤞
    module Enums
      module_function

      extend Dry::Configurable

      # @return [Hash{String=>String}] Used in Accession.AccessionType
      setting :accession_type, reader: true, default: {
        "1" => "accession",
        "2" => "loan, returned",
        "3" => "temporary custody",
        "4" => "temporary custody, returned",
        "5" => "loan, incoming"
      }

      # @return [Hash{String=>String}] Used in
      #   SiteMappingOptions.hemisphereid
      setting :hemisphere, reader: true, default: {
        "0" => "northern",
        "1" => "southern"
      }

      # @return [Hash{String=>String}] Used in CatalogItem.ItemType
      setting :item_type, reader: true, default: {
        "1" => "object",
        "2" => "photo",
        "3" => "archives",
        "4" => "library",
        "5" => "deaccessioned"
      }

      # @return [Hash{String=>String}] Used in
      #   CatalogItemCondition.maintenanceperiodicity
      setting :maintenance_periodicity, reader: true, default: {
        "0" => "0 - Need enum display value",
        "1" => "1 - Need enum display value",
        "2" => "2 - Need enum display value",
        "3" => "monthly",
        "4" => "quarterly",
        "5" => "six months",
        "6" => "yearly",
        "7" => "7 - Need enum display value",
        "8" => "five years",
        "9" => "never"
      }

      # @return [Hash{String=>String}] Used in LocationHistoryItem.MoveTypeId
      setting :move_type, reader: true, default: {
        "0" => "Temp",
        "1" => "Home",
        "2" => "Home",
        "3" => "Temp"
      }

      # @return [Hash{String=>String}] Used in LexiconItem.objectnametypeid
      setting :object_name_type, reader: true, default: {
        "0" => "primary",
        "1" => "secondary",
        "2" => "tertiary"
      }

      # @return [Hash{String=>String}] Used in
      #   ContactAddressAndPhoneNumbers.primaryphonenumbertypeid,
      #   ContactAddressAndPhoneNumbers.secondaryphonenumbertypeid,
      #   ContactAddressAndPhoneNumbers.otherphonenumber1typeid,
      #   ContactAddressAndPhoneNumbers.otherphonenumber2typeid,
      #   LoanContactInformation.primaryphonenumbertype,
      #   LoanContactInformation.secondaryphonenumbertype,
      #   LoanContactInformation.otherphonenumbertype
      setting :phone_number_type, reader: true, default: {
        "0" => nil, # displays as "None of the Above"
        "1" => "home",
        "2" => "mobile",
        "3" => "work",
        "4" => "fax"
      }

      # @return [Hash{String=>String}] Used in
      #   AccessionInsuranceInformation.InsuredBy,
      #   AccessionShippingInformation.TransportationCostPaidBy,
      #   LoanInsuranceInformation.InsuredBy,
      #   LoanShippingInformation.TransportationCostPaidBy,
      #   ExhibitInsuranceInformation.InsuredBy,
      #   ExhibitShippingInformation.TransportationCostPaidBy
      setting :responsible_party, reader: true, default: {
        "0" => nil, # displays as "None Selected"
        "1" => "borrower",
        "2" => "lender"
      }

      # @return [Hash{String=>String}] Used in
      #   CatalogItemNotesAndLegal.webright
      setting :web_right, reader: true, default: {
        "1" => "copyright not evaluated",
        "2" => "copyright undetermined",
        "3" => "in copyright"
      }
    end
  end
end
