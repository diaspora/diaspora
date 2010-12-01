# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oa-enterprise}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James A. Rosen", "Ping Yu"]
  s.date = %q{2010-10-25}
  s.description = %q{Enterprise strategies for OmniAuth.}
  s.email = %q{james.a.rosen@gmail.com}
  s.files = ["lib/omniauth/enterprise.rb", "lib/omniauth/strategies/cas/configuration.rb", "lib/omniauth/strategies/cas/service_ticket_validator.rb", "lib/omniauth/strategies/cas.rb", "lib/omniauth/strategies/ldap/adaptor.rb", "lib/omniauth/strategies/ldap.rb", "README.rdoc", "LICENSE.rdoc", "CHANGELOG.rdoc"]
  s.homepage = %q{http://github.com/intridea/omniauth}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Enterprise strategies for OmniAuth.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<oa-core>, ["= 0.1.6"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.4.2"])
      s.add_runtime_dependency(%q<net-ldap>, ["~> 0.1.1"])
      s.add_runtime_dependency(%q<rubyntlm>, ["~> 0.1.1"])
      s.add_runtime_dependency(%q<pyu-ruby-sasl>, ["~> 0.0.3.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<mg>, ["~> 0.0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_development_dependency(%q<webmock>, ["~> 1.3.4"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.5.4"])
      s.add_development_dependency(%q<json>, ["~> 1.4.3"])
    else
      s.add_dependency(%q<oa-core>, ["= 0.1.6"])
      s.add_dependency(%q<nokogiri>, ["~> 1.4.2"])
      s.add_dependency(%q<net-ldap>, ["~> 0.1.1"])
      s.add_dependency(%q<rubyntlm>, ["~> 0.1.1"])
      s.add_dependency(%q<pyu-ruby-sasl>, ["~> 0.0.3.1"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<mg>, ["~> 0.0.8"])
      s.add_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_dependency(%q<webmock>, ["~> 1.3.4"])
      s.add_dependency(%q<rack-test>, ["~> 0.5.4"])
      s.add_dependency(%q<json>, ["~> 1.4.3"])
    end
  else
    s.add_dependency(%q<oa-core>, ["= 0.1.6"])
    s.add_dependency(%q<nokogiri>, ["~> 1.4.2"])
    s.add_dependency(%q<net-ldap>, ["~> 0.1.1"])
    s.add_dependency(%q<rubyntlm>, ["~> 0.1.1"])
    s.add_dependency(%q<pyu-ruby-sasl>, ["~> 0.0.3.1"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<mg>, ["~> 0.0.8"])
    s.add_dependency(%q<rspec>, ["~> 1.3.0"])
    s.add_dependency(%q<webmock>, ["~> 1.3.4"])
    s.add_dependency(%q<rack-test>, ["~> 0.5.4"])
    s.add_dependency(%q<json>, ["~> 1.4.3"])
  end
end
