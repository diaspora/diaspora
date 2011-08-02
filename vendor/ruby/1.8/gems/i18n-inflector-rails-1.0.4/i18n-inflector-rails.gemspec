# encoding: utf-8

# This is just a helper file for those including directly from sources.
# Real building follows the instructions in the hoe section of Rakefile.

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'i18n-inflector-rails/version'

Gem::Specification.new do |s|
  s.name         = I18n::Inflector::Rails::NAME
  s.version      = I18n::Inflector::Rails::VERSION
  s.authors      = [I18n::Inflector::Rails::DEVELOPER]
  s.email        = I18n::Inflector::Rails::EMAIL
  s.homepage     = I18n::Inflector::Rails::URL
  s.summary      = I18n::Inflector::Rails::SUMMARY
  s.description  = I18n::Inflector::Rails::DESCRIPTION

  s.files        = Dir.glob("{ci,lib,spec,docs}/**/**") + %w(init.rb Gemfile .rspec .yardopts README.rdoc LGPL-LICENSE ChangeLog Manifest.txt)
  s.extra_rdoc_files = ["README.rdoc", "docs/HISTORY", "docs/LGPL-LICENSE", "docs/COPYING"]
  s.rdoc_options = ["--main", "README.rdoc", "--charset=UTF-8"]
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_rubygems_version = '>= 1.4.0'
  s.specification_version = 3

  s.add_dependency 'i18n-inflector',          '~> 2.6'
  s.add_dependency 'railties',                '~> 3.0'
  s.add_dependency 'actionpack',              '~> 3.0'
  s.add_development_dependency 'rspec',       '>= 2.6.0'
  s.add_development_dependency 'yard',        '>= 0.7.2'
  s.add_development_dependency 'bundler',     '>= 1.0.10'
  s.add_development_dependency 'hoe-bundler', '>= 1.1.0'
  s.add_development_dependency 'hoe-yard',    '>= 0.1.2'
end
