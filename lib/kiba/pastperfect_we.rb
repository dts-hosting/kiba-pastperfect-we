# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "kiba/extend"
require "yaml"
require "zeitwerk"

# Needed because these are extended before Zeitwerk code loading is set up
require_relative "pastperfect_we/base_config"
require_relative "pastperfect_we/util_config"

# dev
require "pry"

module Kiba
  # Application loading, base configuration, and top-level convenience methods
  module PastperfectWe
    ::Ppwe = Kiba::PastperfectWe

    module_function

    extend Dry::Configurable

    extend Ppwe::UtilConfig
    set_up_util_config

    extend Ppwe::BaseConfig

    def loader
      @loader ||= setup_loader
    end

    def setup_loader
      puts "LOADING KIBA-PPWE" if verbose?
      base_config
      @loader = Zeitwerk::Loader.new
      @loader.collapse(File.join(__dir__, "pastperfect_we", "config"))
      @loader.push_dir(
        File.expand_path(__FILE__).delete_suffix(".rb"),
        namespace: Kiba::PastperfectWe
      )
      @loader.inflector.inflect(
        "version" => "VERSION"
      )
      jobs = File.join(__dir__, "pastperfect_we", "jobs")
      transforms = File.join(__dir__, "pastperfect_we", "transforms")
      @loader.do_not_eager_load(jobs, transforms)
      @loader.enable_reloading
      @loader.setup
      @loader
    end
    private_class_method(:setup_loader)

    def reload! = @loader.reload

    def configs = Kiba::Extend.project_configs
  end
end

Kiba::PastperfectWe.loader
Kiba::Extend.config.config_namespaces << Kiba::PastperfectWe
