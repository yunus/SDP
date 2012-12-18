# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sdp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yunus Durmus"]
  gem.email         = ["yunus@yanis.com"]
  gem.description   = %q{Smart Discovery Protocol implementation}
  gem.summary       = %q{Smart Discovery Protocol}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sdp"
  gem.require_paths = ["lib"]
  gem.version       = Sdp::VERSION
  gem.platform 		= Gem::Platform::RUBY
  spec.bindir 		= 'bin'

  gem.required_ruby_version = '~> 1.9.3'
  gem.requirements << "Since we are using raw sockets, you should run the codes
 in sudo or rvmsudo if you are using rvm."
  gem.requirements << "'racket' gem is also required but its modified version in git://github.com/yunus/racket.git" 
  gem.add_dependency('linkeddata')
  gem.add_dependency('sparql')
  gem.add_dependency('thor')
end
