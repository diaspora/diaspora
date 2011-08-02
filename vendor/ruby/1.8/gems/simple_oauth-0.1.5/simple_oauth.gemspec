# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simple_oauth/version', __FILE__)

Gem::Specification.new do |spec|
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'mocha', '~> 0.9'
  spec.add_development_dependency 'rake', '~> 0.8'
  spec.add_development_dependency 'simplecov', '~> 0.4'
  spec.add_development_dependency 'turn', '~> 0.8'
  spec.add_development_dependency 'yard', '~> 0.6'
  spec.authors = ['Steve Richert', 'Erik Michaels-Ober']
  spec.description = 'Simply builds and verifies OAuth headers'
  spec.email = ['steve.richert@gmail.com', 'sferik@gmail.com']
  spec.files = `git ls-files`.split("\n")
  spec.homepage = 'http://github.com/laserlemon/simple_oauth'
  spec.name = 'simple_oauth'
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if spec.respond_to? :required_rubygems_version=
  spec.summary = spec.description
  spec.test_files = `git ls-files -- test/**/*_test.rb`.split("\n")
  spec.version = SimpleOAuth::Version::STRING
end
