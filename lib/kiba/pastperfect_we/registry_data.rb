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
          Ppwe::Table.data.values.each do |filedata|
            jobkey = filedata[:key]

            register jobkey, {
              path: filedata[:preprocesspath],
              creator: {
                callee: Ppwe::Jobs::Preprocess,
                args: {
                  source: :"orig__#{filedata[:key]}",
                  dest: :"preprocess__#{jobkey}"
                }
              },
              tags: %i[preprocess]
            }
          end
        end
      end

      def register_files
        puts "Registering `register_files` entries from Ppwe" if Ppwe.debug?
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
