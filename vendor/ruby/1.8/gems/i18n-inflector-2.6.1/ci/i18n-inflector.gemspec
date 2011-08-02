# encoding: utf-8

lib = File.expand_path('../../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'i18n-inflector/version'

Gem::Specification.new do |s|
  s.name         = I18n::Inflector::NAME
  s.version      = I18n::Inflector::VERSION
  s.authors      = [I18n::Inflector::DEVELOPER]
  s.email        = I18n::Inflector::EMAIL
  s.homepage     = I18n::Inflector::URL
  s.summary      = I18n::Inflector::SUMMARY
  s.description  = I18n::Inflector::DESCRIPTION

  s.files        = Dir.glob("{ci,lib,spec,docs}/**/**") + %w(Gemfile .yardopts README.rdoc LGPL-LICENSE ChangeLog Manifest.txt)
  s.extra_rdoc_files = ["README.rdoc", "docs/USAGE", "docs/EXAMPLES", "docs/TODO", "docs/HISTORY", "docs/LEGAL", "docs/LGPL", "docs/COPYING"]
  s.rdoc_options = [ "--charset=UTF-8", "--main", "README.rdoc"]
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_rubygems_version = '>= 1.4.0'
  s.specification_version = 3

  s.add_dependency             'i18n',              '>= 0.4.1'
  s.add_development_dependency 'test_declarative',  '>= 0.0.5'
  s.add_development_dependency 'rspec',             '>= 2.3.0'
  s.add_development_dependency 'yard',              '>= 0.7.2'
  s.add_development_dependency 'bundler',           '>= 1.0.15'
  s.add_development_dependency 'hoe-yard',          '>= 0.1.2'
  s.add_development_dependency 'hoe-bundler',       '>= 1.1.0'

end
