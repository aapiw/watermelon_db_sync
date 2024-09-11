# frozen_string_literal: true

require_relative "lib/watermelon_db_sync/version"

Gem::Specification.new do |spec|
  spec.name = "watermelon_db_sync"
  spec.version = WatermelonDbSync::VERSION
  spec.authors = ["Yasfi"]
  spec.email = ["yasfi.fauzie@gmail.com"]

  spec.summary = "Make synchronize pull & push easier & faster."
  spec.description = "Make synchronize pull & push easier & faster."
  spec.homepage = "https://github.com/aapiw/watermelon_db_sync"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aapiw/watermelon_db_sync"
  spec.metadata["changelog_uri"] = "https://github.com/aapiw/watermelon_db_sync"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_dependency "activesupport", "~> 7.0.8"
  spec.add_dependency "thor"



  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
