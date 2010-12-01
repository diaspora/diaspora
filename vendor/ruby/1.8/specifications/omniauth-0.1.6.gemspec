# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{omniauth}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2010-10-25}
  s.description = %q{OmniAuth is an authentication framework that that separates the concept of authentiation from the concept of identity, providing simple hooks for any application to have one or multiple authentication providers for a user.}
  s.email = %q{michael@intridea.com}
  s.files = ["lib/omniauth.rb", "README.rdoc", "LICENSE.rdoc", "CHANGELOG.rdoc"]
  s.homepage = %q{http://github.com/intridea/omniauth}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rack middleware for standardized multi-provider authentication.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<oa-core>, ["= 0.1.6"])
      s.add_runtime_dependency(%q<oa-oauth>, ["= 0.1.6"])
      s.add_runtime_dependency(%q<oa-basic>, ["= 0.1.6"])
      s.add_runtime_dependency(%q<oa-openid>, ["= 0.1.6"])
      s.add_runtime_dependency(%q<oa-enterprise>, ["= 0.1.6"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<mg>, ["~> 0.0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_development_dependency(%q<webmock>, ["~> 1.3.4"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.5.4"])
      s.add_development_dependency(%q<json>, ["~> 1.4.3"])
    else
      s.add_dependency(%q<oa-core>, ["= 0.1.6"])
      s.add_dependency(%q<oa-oauth>, ["= 0.1.6"])
      s.add_dependency(%q<oa-basic>, ["= 0.1.6"])
      s.add_dependency(%q<oa-openid>, ["= 0.1.6"])
      s.add_dependency(%q<oa-enterprise>, ["= 0.1.6"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<mg>, ["~> 0.0.8"])
      s.add_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_dependency(%q<webmock>, ["~> 1.3.4"])
      s.add_dependency(%q<rack-test>, ["~> 0.5.4"])
      s.add_dependency(%q<json>, ["~> 1.4.3"])
    end
  else
    s.add_dependency(%q<oa-core>, ["= 0.1.6"])
    s.add_dependency(%q<oa-oauth>, ["= 0.1.6"])
    s.add_dependency(%q<oa-basic>, ["= 0.1.6"])
    s.add_dependency(%q<oa-openid>, ["= 0.1.6"])
    s.add_dependency(%q<oa-enterprise>, ["= 0.1.6"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<mg>, ["~> 0.0.8"])
    s.add_dependency(%q<rspec>, ["~> 1.3.0"])
    s.add_dependency(%q<webmock>, ["~> 1.3.4"])
    s.add_dependency(%q<rack-test>, ["~> 0.5.4"])
    s.add_dependency(%q<json>, ["~> 1.4.3"])
  end
end
