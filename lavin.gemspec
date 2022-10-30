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
  spec.required_ruby_version = ">= 3.0.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sammyhenningsson/lavin"
  spec.metadata["changelog_uri"] = "https://github.com/sammyhenningsson/lavin/CHANGELOG"
  spec.cert_chain  = ['certs/sammyhenningsson.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem')

  spec.executables   = ["lavin"]
  spec.require_paths = ["lib"]
  spec.files         = Dir['lib/**/*rb']

  spec.add_dependency "async", "~> 2.2"
  spec.add_dependency "async-http", "~> 0.59"
  spec.add_dependency "sinatra", "~> 3.0"

  spec.add_development_dependency "debug", "~> 1.6"
  spec.add_development_dependency "standard", "~> 1.16"
end
