# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module RegistryData
      module_function

      def register
        if Ppwe.debug?
          puts "Auto-registering files in configured directories..."
        end

        Ppwe.auto_register_dirs.each do |dirname, ns|
          register_dir_files(
            dir: File.join(Ppwe.datadir, dirname.to_s), ns: ns
          )
        end

        register_orig_files
        register_preprocess_jobs
        register_files

        # # This needs to be added if you are using the IterativeCleanup mixin
        # #  in your project. It causes all the automagically defined cleanup
        # #  jobs to be registered.
        # Kiba::Extend::Utils::IterativeCleanupJobRegistrar.call

        # We do not finalize here because it is assumed that the individual
        #   campus project uses this, adds to it, calls
        #   :post_client_registration, and then finalizes
      end

      # Called by client project after its files are registered. Handles any
      #   automatic stuff that needs to be done after that.
      def post_client_registration
        if Ppwe.debug?
          puts "Doing post-client config/file registration manipulation"
        end

        register_non_iterative_cleanup_supplied
      end

      def register_orig_files
        Ppwe.registry.namespace("orig") do
          Ppwe::Table.data.values.each do |filedata|
            jobkey = filedata[:key]

            register jobkey, {
              path: filedata[:origpath],
              supplied: true,
              tags: %i[orig]
            }
          end
        end
      end

      def register_preprocess_jobs
        Ppwe.registry.namespace("preprocess") do
          Ppwe::Table.data.each do |name, filedata|
            jobkey = filedata[:key]
            jobhash = {
              path: filedata[:preprocesspath],
              creator: {
                callee: Ppwe::Jobs::Preprocess,
                args: {source: :"orig__#{filedata[:key]}",
                       dest: :"preprocess__#{jobkey}",
                       tablename: name}
              },
              tags: [:preprocess, jobkey.to_sym],
              lookup_on: Ppwe.lookup_column_for(name)
            }.compact

            register jobkey, jobhash
          end
        end
      end

      def register_files
        puts "Registering `register_files` entries from Ppwe" if Ppwe.debug?

        Ppwe.registry.namespace("prep") do
          Ppwe::Table.data
            .reject { |key, _val| key.end_with?("CustomField") }
            .each do |name, filedata|
              entry = Ppwe::RegistryData.create_regular_prep_job_hash(
                name, filedata
              )
              next unless entry

              register(*entry)
            end

          Ppwe::Table.data
            .select { |key, _val| key.end_with?("CustomField") }
            .each do |name, filedata|
              entry = Ppwe::RegistryData.custom_field_prep_job_hash(
                name, filedata
              )
              next unless entry

              register(*entry)
            end
        end

        Ppwe.registry.namespace("accession") do
          combined_hdrs = %i[id accessiontype number]
          combined_hdrs << Ppwe.review_target_field if Ppwe.mode == :review

          register :combined, {
            path: File.join(Ppwe.wrkdir, "accession_combined.csv"),
            creator: Ppwe::Jobs::Accession::Combined,
            tags: %i[combined accession],
            lookup_on: Ppwe.lookup_column_for("Accession"),
            dest_special_opts: {initial_headers: combined_hdrs}
          }
          register :item_type_lookup, {
            path: File.join(Ppwe.wrkdir, "accession_item_type_lookup.csv"),
            creator: Ppwe::Jobs::Accession::ItemTypeLookup,
            tags: %i[combined accession],
            lookup_on: :accessionid
          }
        end

        Ppwe.registry.namespace("catalog_item") do
          dir = if Ppwe.mode == :migration
            Ppwe.wrkdir
          else
            File.join(Ppwe.datadir, "for_review")
          end

          register :archaeology, {
            path: File.join(dir, "catalog_item_archaeology.csv"),
            creator: Ppwe::Jobs::CatalogItem::Archaeology,
            tags: %i[combined catalog_item archaeology],
            lookup_on: Ppwe.lookup_column_for("CatalogItemArchaeology"),
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :archive, {
            path: File.join(dir, "catalog_item_archive.csv"),
            creator: Ppwe::Jobs::CatalogItem::Archive,
            tags: %i[combined catalog_item archive],
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :base, {
            path: File.join(Ppwe.wrkdir, "catalog_item_base.csv"),
            creator: Ppwe::Jobs::CatalogItem::Base,
            tags: %i[combined catalog_item],
            lookup_on: Ppwe.lookup_column_for("CatalogItemBase"),
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :basic_info, {
            path: File.join(dir, "catalog_item_basic_info.csv"),
            creator: Ppwe::Jobs::CatalogItem::BasicInfo,
            tags: %i[combined catalog_item],
            lookup_on: :catalogitemid,
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields +
                Ppwe::CatalogItem.basic_info_fields
            }
          }
          register :audit_and_system_info, {
            path: File.join(dir, "catalog_item_audit_and_system_info.csv"),
            creator: Ppwe::Jobs::CatalogItem::AuditAndSystemInfo,
            tags: %i[combined catalog_item],
            lookup_on: :catalogitemid,
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields +
                Ppwe::CatalogItem.audit_and_system_info_fields
            }
          }
          register :custom_field_data, {
            path: File.join(dir, "catalog_item_custom_field_data.csv"),
            creator: Ppwe::Jobs::CatalogItem::CustomFieldData,
            tags: %i[combined catalog_item customfields],
            lookup_on: :catalogitemid,
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :deaccession_and_removal, {
            path: File.join(dir, "catalog_item_deaccession_and_removal.csv"),
            creator: Ppwe::Jobs::CatalogItem::DeaccessionAndRemoval,
            tags: %i[combined catalog_item],
            lookup_on: :catalogitemid,
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields +
                Ppwe::CatalogItem.deaccession_and_removal_fields
            }
          }
          register :history, {
            path: File.join(dir, "catalog_item_history.csv"),
            creator: Ppwe::Jobs::CatalogItem::History,
            tags: %i[combined catalog_item history],
            lookup_on: Ppwe.lookup_column_for("CatalogItemHistory"),
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :id_name_class, {
            path: File.join(dir, "catalog_item_id_name_class.csv"),
            creator: Ppwe::Jobs::CatalogItem::IdNameClass,
            tags: %i[combined catalog_item lexicon],
            lookup_on: :catalogitemid,
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields +
                Ppwe::CatalogItem.id_name_class_fields
            }
          }
          register :map, {
            path: File.join(dir, "catalog_item_map.csv"),
            creator: Ppwe::Jobs::CatalogItem::Map,
            tags: %i[combined catalog_item map],
            lookup_on: Ppwe.lookup_column_for("CatalogItemMap"),
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :music, {
            path: File.join(dir, "catalog_item_music.csv"),
            creator: Ppwe::Jobs::CatalogItem::Music,
            tags: %i[combined catalog_item music],
            lookup_on: Ppwe.lookup_column_for("CatalogItemMusic"),
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :photo, {
            path: File.join(dir, "catalog_item_photo.csv"),
            creator: Ppwe::Jobs::CatalogItem::Photo,
            tags: %i[combined catalog_item photo],
            lookup_on: Ppwe.lookup_column_for("CatalogItemPhoto"),
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
          register :subject_info, {
            path: File.join(dir, "catalog_item_subject_info.csv"),
            creator: Ppwe::Jobs::CatalogItem::SubjectInfo,
            tags: %i[combined catalog_item subject_info],
            lookup_on: :catalogitemid,
            dest_special_opts: {
              initial_headers: Ppwe::CatalogItem.base_fields
            }
          }
        end

        Ppwe.registry.namespace("condition_report") do
          register :combined, {
            path: File.join(Ppwe.wrkdir, "condition_report_combined.csv"),
            creator: Ppwe::Jobs::ConditionReport::Combined,
            tags: %i[combined condition_report],
            lookup_on: Ppwe.lookup_column_for("ConditionReport")
          }
        end

        Ppwe.registry.namespace("contact") do
          register :combined, {
            path: File.join(Ppwe.wrkdir, "contact_combined.csv"),
            creator: Ppwe::Jobs::Contact::Combined,
            tags: %i[combined contact],
            lookup_on: Ppwe.lookup_column_for("Contact")
          }
        end

        Ppwe.registry.namespace("dictionary") do
          register :filters, {
            path: File.join(Ppwe.wrkdir, "dictionary_filters.csv"),
            creator: Ppwe::Jobs::Dictionary::Filters,
            tags: %i[dictionary],
            lookup_on: :dictionaryid
          }
          register :usage, {
            path: File.join(Ppwe.wrkdir, "dictionary_usage.csv"),
            creator: Ppwe::Jobs::Dictionary::Usage,
            tags: %i[dictionary],
            lookup_on: :dictionaryid
          }
          register :unused_items, {
            path: File.join(Ppwe.wrkdir, "dictionary_unused_items.csv"),
            creator: Ppwe::Jobs::Dictionary::UnusedItems,
            tags: %i[dictionary]
          }
        end

        Ppwe.registry.namespace("exhibit") do
          register :combined, {
            path: File.join(Ppwe.wrkdir, "exhibit_combined.csv"),
            creator: Ppwe::Jobs::Exhibit::Combined,
            tags: %i[combined exhibit],
            lookup_on: Ppwe.lookup_column_for("exhibit")
          }
        end

        Ppwe.registry.namespace("exhibit_catalog_items") do
          register :combined, {
            path: File.join(Ppwe.wrkdir, "exhibit_catalog_items_combined.csv"),
            creator: Ppwe::Jobs::ExhibitCatalogItems::Combined,
            tags: %i[combined exhibit_catalog_items],
            lookup_on: Ppwe.lookup_column_for("exhibit_catalog_items")
          }
        end

        Ppwe.registry.namespace("loan_catalog_items") do
          register :combined, {
            path: File.join(Ppwe.wrkdir, "loan_catalog_items_combined.csv"),
            creator: Ppwe::Jobs::LoanCatalogItems::Combined,
            tags: %i[combined loan_catalog_items],
            lookup_on: Ppwe.lookup_column_for("loan_catalog_items")
          }
        end

        Ppwe.registry.namespace("location") do
          register :prefixed, {
            path: File.join(Ppwe.wrkdir, "location_prefixed.csv"),
            creator: Ppwe::Jobs::Location::Prefixed,
            tags: %i[location],
            lookup_on: Ppwe.lookup_column_for("location"),
            desc: "Merges field names from CatalogItemLocationFieldNames "\
              "in as value prefixes and adds a :location column combining "\
              "prefixed values into one value for merging"
          }
        end

        Ppwe.registry.namespace("person") do
          register :combined, {
            path: File.join(Ppwe.wrkdir, "person_combined.csv"),
            creator: Ppwe::Jobs::Person::Combined,
            tags: %i[combined person],
            lookup_on: Ppwe.lookup_column_for("Person")
          }
        end
      end
      private_class_method :register_files

      # Because these are supplied, not derived by the project, they do not need
      #   `creator` attributes defined.
      def register_dir_files(dir:, ns:)
        Ppwe.registry.namespace(ns) do
          Dir.children(dir).select do |file|
            File.extname(file) == ".csv"
          end.each do |csvfile|
            key = csvfile.delete_suffix(".csv").to_sym

            register key, {
              path: File.join(dir, csvfile),
              supplied: true,
              tags: [key, ns.to_sym]
            }
          end
        end
      end
      private_class_method :register_dir_files

      def create_regular_prep_job_hash(name, filedata)
        jobmod = Ppwe::Jobs::Prep.constants.find { |c| c == name.to_sym }
        return unless jobmod

        [
          filedata[:key],
          regular_prep_job_hash(jobmod, name, filedata)
        ]
      end

      def regular_prep_job_hash(jobmod, name, filedata)
        result = {
          path: File.join(Ppwe.wrkdir, "#{filedata[:key]}_prep.csv"),
          creator: {
            callee: "Ppwe::Jobs::Prep::#{jobmod}".constantize,
            args: {source: :"preprocess__#{filedata[:key]}",
                   dest: :"prep__#{filedata[:key]}"}
          },
          tags: [:prep, filedata[:key].to_sym],
          lookup_on: Ppwe.lookup_column_for(name)
        }.compact
        return result unless Ppwe::Prep.dest_special_opts.key?(name)

        result[:dest_special_opts] = Ppwe::Prep.dest_special_opts[name]
        result
      end

      def custom_field_prep_job_hash(name, filedata)
        [
          filedata[:key],
          {
            path: File.join(Ppwe.wrkdir, "#{filedata[:key]}_prep.csv"),
            creator: {
              callee: Ppwe::Jobs::Prep::CustomFieldTable,
              args: {source: :"preprocess__#{filedata[:key]}",
                     dest: :"prep__#{filedata[:key]}"}
            },
            tags: [:prep, filedata[:key].to_sym, :customfields],
            lookup_on: Ppwe.lookup_column_for(name)
          }.compact
        ]
      end

      def register_non_iterative_cleanup_supplied
        if Ppwe.debug?
          puts "Registering non-iterative cleanup-related supplied files"
        end

        dir = File.join(Ppwe.datadir, "supplied")
        return unless Dir.exist?(dir)

        iterative_cleanup_files = iterative_cleanup_supplied_files(dir)
        to_register = Dir.new(dir)
          .children
          .select do |child|
            child.end_with?(".csv") &&
              iterative_cleanup_files.none? { |path| path.end_with?(child) }
          end
        return if to_register.empty?

        lookup_keys = {
          org_person_refnames: :term
        }

        Ppwe.registry.namespace("supplied") do
          to_register.each do |csvfile|
            key = csvfile.delete_suffix(".csv").to_sym
            hash = {
              path: File.join(dir, csvfile),
              supplied: true,
              tags: [key, :supplied]
            }
            hash[:lookup_on] = lookup_keys[key] if lookup_keys.key?(key)

            register key, hash
          end
        end
      end
      private_class_method :register_non_iterative_cleanup_supplied

      def iterative_cleanup_supplied_files(dir)
        Csu.registry
          .entries
          .map { |entry| supplied_file_name(entry[:path], dir) }
          .compact
      end
      private_class_method :iterative_cleanup_supplied_files

      def supplied_file_name(path, dir)
        return unless path.start_with?(dir)

        path
      end
      private_class_method :supplied_file_name
    end
  end
end
