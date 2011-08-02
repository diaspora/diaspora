# -*- encoding: utf-8 -*-
require File.expand_path('../lib/multi_xml/version', __FILE__)

Gem::Specification.new do |s|
  s.add_development_dependency('libxml-ruby', '~> 1.1')
  s.add_development_dependency('maruku', '~> 0.6')
  s.add_development_dependency('nokogiri', '~> 1.4')
  s.add_development_dependency('rake', '~> 0.8')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('simplecov', '~> 0.4')
  s.add_development_dependency('yard', '~> 0.6')
  s.add_development_dependency('ZenTest', '~> 4.5')
  s.name        = 'multi_xml'
  s.version     = MultiXml::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Erik Michaels-Ober"]
  s.email       = ['sferik@gmail.com']
  s.homepage    = 'http://rubygems.org/gems/multi_xml'
  s.summary     = %q{A generic swappable back-end for XML parsing}
  s.description = %q{A gem to provide swappable XML backends utilizing LibXML, Nokogiri, or REXML.}
  s.rubyforge_project = 'multi_xml'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
