# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{i18n-inflector-rails}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pawe\305\202 Wilk"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDKjCCAhKgAwIBAgIBADANBgkqhkiG9w0BAQUFADA7MQ8wDQYDVQQDDAZzaWVm\nY2ExEzARBgoJkiaJk/IsZAEZFgNnbnUxEzARBgoJkiaJk/IsZAEZFgNvcmcwHhcN\nMDkwNjA2MDkwODA5WhcNMTAwNjA2MDkwODA5WjA7MQ8wDQYDVQQDDAZzaWVmY2Ex\nEzARBgoJkiaJk/IsZAEZFgNnbnUxEzARBgoJkiaJk/IsZAEZFgNvcmcwggEiMA0G\nCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCdk4+9ieSx2I2OPslPcj/LjajwtsrH\nmev6Fs3xK9hdDIbbLuQM9AypBS7NeKP/2YToEOGxsvzcpFzL2Ah71cP6Yfn+Z2Yo\nzvqpAx5/nl79PrJKvjlkdzVNOFBp/EOkLK67QK4Pv97ABnG2PkF4FokqOjuNHLM7\n47OkJPvFyfHyMBDZN7EFljBBNm3IuQRTiO48e5Jcp3L761PWOvCpnV8wiga0Wwt3\n98Gmy7c1nWzfbQc1wHwKLPICY/aidKU20KymSHG63BSW5pO2cXZecIeYjw5YNjGA\nM1RZMiwT7QJ9W86VVP+8EqbJKJOS95xlmQTHjPK56yXv8GiuyLQHpPh5AgMBAAGj\nOTA3MAkGA1UdEwQCMAAwHQYDVR0OBBYEFKOKspZONq4bt5D2DEexB+vsMB2GMAsG\nA1UdDwQEAwIEsDANBgkqhkiG9w0BAQUFAAOCAQEAUh0LnB4o5XKpH3yOxavEyp9X\nNen2e854wsSjAr0waSVzEt3XxY1voyIE6WCGxZJU//40CR0Be7j5CcsJsDU2CZyZ\n8SXN1/mZjMqWvYyEMSfQP4XzkFSOuyDcoDAf43OGhOhdv5Jcs/Et/FH6DgWYwRxq\nRtATRWON5R99ugPeRb7i1nIpnzGEBA9V32r6r959Bp3XjkVEXylbItYMqSARaZlY\nqzKSsIUjh7vDyTNqta0DjSgCk26dhnOwc0hmzhvVZtBwfZritSVhfCLp5uFwqCqY\nNK3TIZaPCh1S2/ES6wXNvjQ+5EnEEL9j/pSEop9DYEBPaM2WDVR5i0jJTAaRWw==\n-----END CERTIFICATE-----\n"]
  s.date = %q{2011-07-10 00:00:00.000000000Z}
  s.description = %q{Plug-in that provides I18n Inflector module integration with Rails.}
  s.email = ["pw@gnu.org"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = [".rspec", ".yardopts", "ChangeLog", "Gemfile", "LGPL-LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "docs/COPYING", "docs/HISTORY", "docs/LEGAL", "docs/LGPL-LICENSE", "docs/TODO", "docs/rdoc.css", "i18n-inflector-rails.gemspec", "init.rb", "lib/i18n-inflector-rails.rb", "lib/i18n-inflector-rails/errors.rb", "lib/i18n-inflector-rails/inflector.rb", "lib/i18n-inflector-rails/options.rb", "lib/i18n-inflector-rails/railtie.rb", "lib/i18n-inflector-rails/version.rb", "spec/inflector_spec.rb", "spec/spec_helper.rb", ".gemtest"]
  s.homepage = %q{https://rubygems.org/gems/i18n-inflector-rails/}
  s.rdoc_options = ["--title", "I18n::Inflector::Rails Documentation", "--quiet"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{i18n-inflector-rails}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{I18n Inflector bindings for Rails}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<i18n-inflector>, ["~> 2.6"])
      s.add_runtime_dependency(%q<railties>, ["~> 3.0"])
      s.add_runtime_dependency(%q<actionpack>, ["~> 3.0"])
      s.add_development_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_development_dependency(%q<yard>, [">= 0.7.2"])
      s.add_development_dependency(%q<rdoc>, [">= 3.8.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.10"])
      s.add_development_dependency(%q<hoe-bundler>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe>, ["~> 2.10"])
    else
      s.add_dependency(%q<i18n-inflector>, ["~> 2.6"])
      s.add_dependency(%q<railties>, ["~> 3.0"])
      s.add_dependency(%q<actionpack>, ["~> 3.0"])
      s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_dependency(%q<yard>, [">= 0.7.2"])
      s.add_dependency(%q<rdoc>, [">= 3.8.0"])
      s.add_dependency(%q<bundler>, [">= 1.0.10"])
      s.add_dependency(%q<hoe-bundler>, [">= 1.1.0"])
      s.add_dependency(%q<hoe>, ["~> 2.10"])
    end
  else
    s.add_dependency(%q<i18n-inflector>, ["~> 2.6"])
    s.add_dependency(%q<railties>, ["~> 3.0"])
    s.add_dependency(%q<actionpack>, ["~> 3.0"])
    s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
    s.add_dependency(%q<rspec>, [">= 2.6.0"])
    s.add_dependency(%q<yard>, [">= 0.7.2"])
    s.add_dependency(%q<rdoc>, [">= 3.8.0"])
    s.add_dependency(%q<bundler>, [">= 1.0.10"])
    s.add_dependency(%q<hoe-bundler>, [">= 1.1.0"])
    s.add_dependency(%q<hoe>, ["~> 2.10"])
  end
end
