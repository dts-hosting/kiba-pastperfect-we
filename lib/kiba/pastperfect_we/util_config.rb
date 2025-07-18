# frozen_string_literal: true

module Kiba
  module PastperfectWe
    # Mixin module to organize config settings controlling how jobs are
    #  run, screen output, etc.
    module UtilConfig
      def set_up_util_config(from_extended = false)
        # For dev/debugging. Set to :verbose to have application print
        #   everything it does to screen. We set this in Kiba::Extend because
        #   a lot of the output behavior is in that library.
        Kiba::Extend.config.job_verbosity = :normal

        # We then create a CSU-level setting that inherits the default value
        #   of Kiba::Extend.job_verbosity, on which we can build
        #   CSU-project-specific functionality
        setting :stdout_mode, default: Kiba::Extend.job_verbosity,
          reader: true

        # Used by Ppwe::RegistryData#register to register directories of files.
        #   Hash keys should be directory names (living under `datadir` for
        #   project) and Hash value will be the registry namespace the files
        #   are registered in.
        setting :auto_register_dirs,
          default: {},
          reader: true

        #################################################################
        # Leave it alone or suffer
        #################################################################
        # @return [Kiba::Extend::FileRegistry]
        setting :registry, default: Kiba::Extend.registry, reader: true

        # This supports protection against errors due to unexpected empty job
        #   output or missing tables
        # @return [Array]
        setting :blank_jobs, default: %i[], reader: true
      end

      def verbose?
        true if %i[verbose debug].include?(stdout_mode)
      end

      def debug?
        true if stdout_mode == :debug
      end

      # methods to delete after development is done

      # @param jobkey [Symbol]
      # @param column [Symbol] keycolumn on which to lookup
      def get_lookup(jobkey:, column:)
        return nil if Ppwe.blank_jobs.include?(jobkey)
        return nil unless job_output?(jobkey)

        Kiba::Extend::Utils::Lookup.csv_to_hash(
          file: Ppwe.registry.resolve(jobkey).path,
          keycolumn: column
        )
      end

      # @param jobkey [Symbol]
      # @return [Boolean]
      def job_output?(jobkey)
        return false if Ppwe.blank_jobs.include?(jobkey)

        result = Kiba::Extend::Job.output?(jobkey)
        Ppwe.blank_jobs << jobkey unless result == true
        result
      end

      # @param jobkey [Symbol]
      # @return [Array<Symbol>]
      def headers_for(jobkey)
        return [] if Ppwe.blank_jobs.include?(jobkey)
        return [] unless job_output?(jobkey)

        job = Ppwe.registry.resolve(jobkey)
        path = job.path

        `head -n 1 #{path}`.chomp
          .split(",")
          .map(&:to_sym)
      end

      # @param jobkey [Symbol]
      # @param drop [Array<Symbol>] fields in addition to any lookup key to drop
      # @return [Array<Symbol>]
      def mergeable_headers_for(jobkey, drop: [])
        all = headers_for(jobkey) - [drop].flatten
        lkupkey = lookup_on_for(jobkey)
        return all unless lkupkey

        all - [lkupkey]
      end

      # Used to find the field that should be set as lookup_on value when
      #   initially creating a registry entry for a job
      # @param tablename [String]
      # @return [Symbol]
      def lookup_column_for(tablename) = Ppwe.lookup_ids.fetch(tablename, :id)

      # Used to find the lookup_on value of a job's registry entry
      # @param jobkey [Symbol]
      # @return [Symbol]
      def lookup_on_for(jobkey) = Ppwe.registry.resolve(jobkey).lookup_on
    end
  end
end
