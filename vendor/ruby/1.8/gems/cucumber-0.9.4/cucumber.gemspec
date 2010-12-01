# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "cucumber/platform"

Gem::Specification.new do |s|
  s.name        = 'cucumber'
  s.version     = Cucumber::VERSION
  s.authors     = ["Aslak Hellesøy"]
  s.description = 'Behaviour Driven Development with elegance and joy'
  s.summary     = "cucumber-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.homepage    = "http://cukes.info"

  s.platform    = Gem::Platform::RUBY
  s.default_executable = "cucumber"
  s.post_install_message = %{
(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)

Thank you for installing cucumber-#{Cucumber::VERSION}.
Please be sure to read http://wiki.github.com/aslakhellesoy/cucumber/upgrading
for important information about this release. Happy cuking!

(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)

}

  s.add_dependency 'gherkin', '~> 2.2.9'
  s.add_dependency 'term-ansicolor', '~> 1.0.5'
  s.add_dependency 'builder', '~> 2.1.2'
  s.add_dependency 'diff-lcs', '~> 1.1.2'
  s.add_dependency 'json', '~> 1.4.6'
  
  s.add_development_dependency 'rake', '~> 0.8.7'
  s.add_development_dependency 'rspec', '~> 2.0.1'
  s.add_development_dependency 'nokogiri', '~> 1.4.3'
  s.add_development_dependency 'prawn', '= 0.8.4'
  s.add_development_dependency 'prawn-layout', '= 0.8.4'
  s.add_development_dependency 'syntax', '~> 1.0.0'
  s.add_development_dependency 'spork', '~> 0.8.4'
#  s.add_development_dependency 'rcov', '~> 0.9.9'

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ["LICENSE", "README.rdoc", "History.txt"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
