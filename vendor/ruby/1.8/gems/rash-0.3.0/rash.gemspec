# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rash/version"

Gem::Specification.new do |s|
  s.name = %q{rash}
  s.authors = ["tcocca"]
  s.date = %q{2010-08-31}
  s.description = %q{simple extension to Hashie::Mash for rubyified keys, all keys are converted to underscore to eliminate horrible camelCasing}
  s.email = %q{tom.cocca@gmail.com}
  s.homepage = %q{http://github.com/tcocca/rash}
  s.rdoc_options = ["--charset=UTF-8"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{simple extension to Hashie::Mash for rubyified keys}

  s.version = Rash::VERSION
  s.platform = Gem::Platform::RUBY

  s.add_dependency "hashie", '~> 1.0.0'
  s.add_development_dependency "rspec", "~> 2.5.0"

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end

