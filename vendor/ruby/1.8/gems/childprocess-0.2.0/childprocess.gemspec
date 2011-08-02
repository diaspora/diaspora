# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "childprocess/version"

Gem::Specification.new do |s|
  s.name        = "childprocess"
  s.version     = ChildProcess::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken"]
  s.email       = ["jari.bakken@gmail.com"]
  s.homepage    = "http://github.com/jarib/childprocess"
  s.summary     = %q{This gem aims at being a simple and reliable solution for controlling external programs running in the background on any Ruby / OS combination.}
  s.description = %q{This gem aims at being a simple and reliable solution for controlling external programs running in the background on any Ruby / OS combination.}

  s.rubyforge_project = "childprocess"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", [">= 2.0.0"]
  s.add_development_dependency "yard", [">= 0"]
  s.add_development_dependency "rake", ["~> 0.8.7"]
  s.add_runtime_dependency "ffi", ["~> 1.0.6"]
end


