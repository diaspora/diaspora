# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth/version', __FILE__)

Gem::Specification.new do |gem|
  %w(oa-basic oa-enterprise oa-core oa-more oa-oauth oa-openid).each do |subgem|
    gem.add_runtime_dependency subgem, OmniAuth::Version::STRING
  end
  gem.authors = ['Michael Bleigh', 'Erik Michaels-Ober']
  gem.description = %q{OmniAuth is an authentication framework that that separates the concept of authentiation from the concept of identity, providing simple hooks for any application to have one or multiple authentication providers for a user.}
  gem.email = ['michael@intridea.com', 'sferik@gmail.com']
  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/intridea/omniauth'
  gem.name = 'omniauth'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  gem.summary = %q{Rack middleware for standardized multi-provider authentication.}
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version = OmniAuth::Version::STRING
end
