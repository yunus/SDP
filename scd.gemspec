# -*- encoding: utf-8 -*-
require File.expand_path('../lib/scd/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yunus Durmus"]
  gem.email         = ["yunusd84@gmail.com"]
  gem.description   = %q{Semantic Capability Discovery protocol implementation}
  gem.summary       = %q{Semantic Capability Discovery protocol}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "scd"
  gem.require_paths = ["lib"]
  gem.version       = Scd::VERSION
  gem.platform = Gem::Platform::RUBY

  gem.required_ruby_version = '~> 1.9.3'
  gem.requirements << "Since we are using raw sockets, you should run the codes
 in sudo or rvmsudo if you are using rvm."
  gem.add_dependency('linkeddata')
  gem.add_dependency('sparql')
end
