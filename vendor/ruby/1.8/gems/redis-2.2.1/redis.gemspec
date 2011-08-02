# -*- encoding: utf-8 -*-

$:.unshift File.expand_path("../lib", __FILE__)
require "redis/version"

Gem::Specification.new do |s|
  s.name = %q{redis}
  s.version = Redis::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ezra Zygmuntowicz", "Taylor Weibley", "Matthew Clark", "Brian McKinney", "Salvatore Sanfilippo", "Luca Guidi", "Michel Martens", "Damian Janowski", "Pieter Noordhuis"]
  s.autorequire = %q{redis}
  s.description = %q{Ruby client library for Redis, the key value storage server}
  s.summary = %q{Ruby client library for Redis, the key value storage server}
  s.email = %q{ez@engineyard.com}
  s.homepage = %q{http://github.com/ezmobius/redis-rb}
  s.rubyforge_project = "redis-rb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
end
