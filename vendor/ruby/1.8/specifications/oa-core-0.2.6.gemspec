# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oa-core}
  s.version = "0.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh", "Erik Michaels-Ober"]
  s.date = %q{2011-05-20}
  s.description = %q{Core strategies for OmniAuth.}
  s.email = ["michael@intridea.com", "sferik@gmail.com"]
  s.files = [".gemtest", ".rspec", ".yardopts", "Gemfile", "LICENSE", "Rakefile", "autotest/discover.rb", "lib/oa-core.rb", "lib/omniauth/builder.rb", "lib/omniauth/core.rb", "lib/omniauth/form.rb", "lib/omniauth/strategy.rb", "lib/omniauth/test.rb", "lib/omniauth/test/phony_session.rb", "lib/omniauth/test/strategy_macros.rb", "lib/omniauth/test/strategy_test_case.rb", "lib/omniauth/version.rb", "oa-core.gemspec", "spec/omniauth/builder_spec.rb", "spec/omniauth/core_spec.rb", "spec/omniauth/strategy_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/intridea/omniauth}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Core strategies for OmniAuth.}
  s.test_files = ["spec/omniauth/builder_spec.rb", "spec/omniauth/core_spec.rb", "spec/omniauth/strategy_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<maruku>, ["~> 0.6"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<ZenTest>, ["~> 4.5"])
    else
      s.add_dependency(%q<maruku>, ["~> 0.6"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_dependency(%q<rake>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.5"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<ZenTest>, ["~> 4.5"])
    end
  else
    s.add_dependency(%q<maruku>, ["~> 0.6"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
    s.add_dependency(%q<rack-test>, ["~> 0.5"])
    s.add_dependency(%q<rake>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.5"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<ZenTest>, ["~> 4.5"])
  end
end
