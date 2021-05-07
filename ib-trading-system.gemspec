require_relative 'lib/trading-system/version'

Gem::Specification.new do |spec|
  spec.name          = "ib-trading-system"
  spec.version       = TradingSystem::VERSION
  spec.authors       = ["Hartmut Bischoff"]
  spec.email         = ["topofocus@gmail.com"]

  spec.summary       = %q{Automatic trading on interactive brokers tws.}
  spec.homepage      = "https://ib-ruby.github.io/ib-doc/"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

#  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.cm/ib-ruby/ib-trading-system"
#  spec.metadata["changelog_uri"] = "https://github.cm/ib-ruby/ib-trading-system/changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


	spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rspec-collection_matchers'
  spec.add_development_dependency 'rspec-its' 

  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_dependency 'enumerable-statistics'
  spec.add_dependency "ib-api"
  spec.add_dependency "ib-extensions"
  spec.add_dependency "ib-technical-analysis"

end
