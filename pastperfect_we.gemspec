# frozen_string_literal: true

require_relative "lib/kiba/pastperfect_we/version"

Gem::Specification.new do |spec|
  spec.name = "pastperfect_we"
  spec.version = Kiba::PastperfectWe::VERSION
  spec.authors = ["Kristina Spurgin"]
  spec.email = ["kristina.spurgin@lyrasis.org"]

  spec.summary = "Shared Kiba ETL setup for Pastperfect Web Edition migrations"
  spec.homepage = "https://github.com/dts-hosting/kiba-pastperfect-we"
  spec.license = "MIT"

  spec.required_ruby_version = ">=3.4.1"
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  #   'allowed_push_host' to allow pushing to a single host or delete this
  #   section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] =
      "https://github.com/dts-hosting/kiba-pastperfect-we"
    spec.metadata["changelog_uri"] =
      "https://github.com/dts-hosting/kiba-pastperfect-we"
  else
    raise "RubyGems 2.0 or newer is required to protect against "\
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  #   into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "asciidoctor"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
end
