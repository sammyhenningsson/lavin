# frozen_string_literal: true

require_relative "lib/lavin/version"

Gem::Specification.new do |spec|
  spec.name          = "lavin"
  spec.version       = Lavin::VERSION
  spec.authors       = ["Sammy Henningsson"]
  spec.email         = ["sammy.henningsson@hemnet.se"]

  spec.summary       = "A framework for loadtesting sites."
  spec.homepage      = "https://github.com/sammyhenningsson/lavin"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sammyhenningsson/lavin"
  spec.metadata["changelog_uri"] = "https://github.com/sammyhenningsson/lavin/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "debug"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
