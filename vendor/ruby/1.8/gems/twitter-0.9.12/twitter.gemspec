# -*- encoding: utf-8 -*-
require File.expand_path("../lib/twitter/version", __FILE__)

Gem::Specification.new do |s|
  s.add_development_dependency("fakeweb", ["~> 1.3.0"])
  s.add_development_dependency("mocha", ["~> 0.9.8"])
  s.add_development_dependency("shoulda", ["~> 2.11.3"])
  s.add_runtime_dependency("hashie", ["~> 0.4.0"])
  s.add_runtime_dependency("httparty", ["~> 0.6.1"])
  s.add_runtime_dependency("oauth", ["~> 0.4.3"])
  s.add_runtime_dependency("multi_json", ["~> 0.0.4"])
  s.authors = ["John Nunemaker", "Wynn Netherland", "Erik Michaels-Ober"]
  s.description = %q{Ruby wrapper for the Twitter API}
  s.email = ["nunemaker@gmail.com"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = `git ls-files`.split("\n")
  s.homepage = "http://rubygems.org/gems/twitter"
  s.name = "twitter"
  s.platform = Gem::Platform::RUBY
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "twitter"
  s.summary = %q{Ruby wrapper for the Twitter API}
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Twitter::VERSION
end
