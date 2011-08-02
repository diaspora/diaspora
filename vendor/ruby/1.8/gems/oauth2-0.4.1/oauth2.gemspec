# -*- encoding: utf-8 -*-
require File.expand_path("../lib/oauth2/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "oauth2"
  s.version = OAuth2::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.description = %q{A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth gem.}
  s.summary = %q{A Ruby wrapper for the OAuth 2.0 protocol.}
  s.email = "michael@intridea.com"
  s.homepage = "http://github.com/intridea/oauth2"
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.add_runtime_dependency("faraday", "~> 0.6.1")
  s.add_runtime_dependency("multi_json", ">= 0.0.5")
  s.add_development_dependency("json_pure", "~> 1.5")
  s.add_development_dependency("rake", "~> 0.8")
  s.add_development_dependency("simplecov", "~> 0.4")
  s.add_development_dependency("rspec", "~> 2.5")
  s.add_development_dependency("ZenTest", "~> 4.5")
end
