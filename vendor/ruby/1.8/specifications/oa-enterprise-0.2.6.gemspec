# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oa-enterprise}
  s.version = "0.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["James A. Rosen", "Ping Yu", "Michael Bleigh", "Erik Michaels-Ober"]
  s.date = %q{2011-05-20}
  s.description = %q{Enterprise strategies for OmniAuth.}
  s.email = ["james.a.rosen@gmail.com", "ping@intridea.com", "michael@intridea.com", "sferik@gmail.com"]
  s.files = [".gemtest", ".rspec", ".yardopts", "Gemfile", "LICENSE", "README.rdoc", "Rakefile", "lib/oa-enterprise.rb", "lib/omniauth/enterprise.rb", "lib/omniauth/strategies/cas.rb", "lib/omniauth/strategies/cas/configuration.rb", "lib/omniauth/strategies/cas/service_ticket_validator.rb", "lib/omniauth/strategies/ldap.rb", "lib/omniauth/strategies/ldap/adaptor.rb", "lib/omniauth/version.rb", "oa-enterprise.gemspec", "spec/fixtures/cas_failure.xml", "spec/fixtures/cas_success.xml", "spec/omniauth/strategies/cas_spec.rb", "spec/omniauth/strategies/ldap_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/intridea/omniauth}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Enterprise strategies for OmniAuth.}
  s.test_files = ["spec/fixtures/cas_failure.xml", "spec/fixtures/cas_success.xml", "spec/omniauth/strategies/cas_spec.rb", "spec/omniauth/strategies/ldap_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, ["= 2.2.4"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.4.2"])
      s.add_runtime_dependency(%q<net-ldap>, ["~> 0.2.2"])
      s.add_runtime_dependency(%q<oa-core>, ["= 0.2.6"])
      s.add_runtime_dependency(%q<pyu-ruby-sasl>, ["~> 0.0.3.1"])
      s.add_runtime_dependency(%q<rubyntlm>, ["~> 0.1.1"])
      s.add_development_dependency(%q<maruku>, ["~> 0.6"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5"])
      s.add_development_dependency(%q<webmock>, ["~> 1.6"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<ZenTest>, ["~> 4.5"])
    else
      s.add_dependency(%q<addressable>, ["= 2.2.4"])
      s.add_dependency(%q<nokogiri>, ["~> 1.4.2"])
      s.add_dependency(%q<net-ldap>, ["~> 0.2.2"])
      s.add_dependency(%q<oa-core>, ["= 0.2.6"])
      s.add_dependency(%q<pyu-ruby-sasl>, ["~> 0.0.3.1"])
      s.add_dependency(%q<rubyntlm>, ["~> 0.1.1"])
      s.add_dependency(%q<maruku>, ["~> 0.6"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_dependency(%q<rake>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.5"])
      s.add_dependency(%q<webmock>, ["~> 1.6"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<ZenTest>, ["~> 4.5"])
    end
  else
    s.add_dependency(%q<addressable>, ["= 2.2.4"])
    s.add_dependency(%q<nokogiri>, ["~> 1.4.2"])
    s.add_dependency(%q<net-ldap>, ["~> 0.2.2"])
    s.add_dependency(%q<oa-core>, ["= 0.2.6"])
    s.add_dependency(%q<pyu-ruby-sasl>, ["~> 0.0.3.1"])
    s.add_dependency(%q<rubyntlm>, ["~> 0.1.1"])
    s.add_dependency(%q<maruku>, ["~> 0.6"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
    s.add_dependency(%q<rack-test>, ["~> 0.5"])
    s.add_dependency(%q<rake>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.5"])
    s.add_dependency(%q<webmock>, ["~> 1.6"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<ZenTest>, ["~> 4.5"])
  end
end
