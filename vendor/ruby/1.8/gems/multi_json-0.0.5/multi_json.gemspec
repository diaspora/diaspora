# -*- encoding: utf-8 -*-
require File.expand_path("../lib/multi_json/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "multi_json"
  s.version = MultiJson::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.description = %q{A gem to provide swappable JSON backends utilizing Yajl::Ruby, the JSON gem, ActiveSupport, or JSON pure.}
  s.summary = %q{A gem to provide swappable JSON backends.}
  s.email = ["michael@intridea.com"]
  s.homepage = "http://github.com/intridea/multi_json"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.add_development_dependency("rake", "~> 0.8")
  s.add_development_dependency("rcov", "~> 0.9")
  s.add_development_dependency("rspec", "~> 2.0")
  s.add_development_dependency("activesupport", "~> 3.0")
  s.add_development_dependency("json", "~> 1.4")
  s.add_development_dependency("json_pure", "~> 1.4")
  s.add_development_dependency("yajl-ruby", "~> 0.7")
end

