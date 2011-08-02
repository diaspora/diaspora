# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oa-openid}
  s.version = "0.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh", "Erik Michaels-Ober"]
  s.date = %q{2011-05-20}
  s.description = %q{OpenID strategies for OmniAuth.}
  s.email = ["michael@intridea.com", "sferik@gmail.com"]
  s.files = [".gemtest", ".rspec", ".yardopts", "Gemfile", "LICENSE", "README.rdoc", "Rakefile", "lib/oa-openid.rb", "lib/omniauth/openid.rb", "lib/omniauth/openid/gapps.rb", "lib/omniauth/strategies/google_apps.rb", "lib/omniauth/strategies/open_id.rb", "lib/omniauth/strategies/steam.rb", "lib/omniauth/version.rb", "oa-openid.gemspec", "spec/omniauth/strategies/open_id_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/intridea/omniauth}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{OpenID strategies for OmniAuth.}
  s.test_files = ["spec/omniauth/strategies/open_id_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<oa-core>, ["= 0.2.6"])
      s.add_runtime_dependency(%q<rack-openid>, ["~> 1.3.1"])
      s.add_runtime_dependency(%q<ruby-openid-apps-discovery>, ["~> 1.2.0"])
      s.add_development_dependency(%q<maruku>, ["~> 0.6"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_development_dependency(%q<webmock>, ["~> 1.6"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<ZenTest>, ["~> 4.5"])
    else
      s.add_dependency(%q<oa-core>, ["= 0.2.6"])
      s.add_dependency(%q<rack-openid>, ["~> 1.3.1"])
      s.add_dependency(%q<ruby-openid-apps-discovery>, ["~> 1.2.0"])
      s.add_dependency(%q<maruku>, ["~> 0.6"])
      s.add_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_dependency(%q<rake>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.5"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_dependency(%q<webmock>, ["~> 1.6"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<ZenTest>, ["~> 4.5"])
    end
  else
    s.add_dependency(%q<oa-core>, ["= 0.2.6"])
    s.add_dependency(%q<rack-openid>, ["~> 1.3.1"])
    s.add_dependency(%q<ruby-openid-apps-discovery>, ["~> 1.2.0"])
    s.add_dependency(%q<maruku>, ["~> 0.6"])
    s.add_dependency(%q<rack-test>, ["~> 0.5"])
    s.add_dependency(%q<rake>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.5"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
    s.add_dependency(%q<webmock>, ["~> 1.6"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<ZenTest>, ["~> 4.5"])
  end
end
