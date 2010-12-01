# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{warden}
  s.version = "0.10.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Neighman"]
  s.date = %q{2010-05-30}
  s.email = %q{has.sox@gmail.com}
  s.extra_rdoc_files = ["LICENSE", "README.textile"]
  s.files = [".gitignore", "History.rdoc", "LICENSE", "README.textile", "Rakefile", "TODO.textile", "lib/warden.rb", "lib/warden/config.rb", "lib/warden/errors.rb", "lib/warden/hooks.rb", "lib/warden/manager.rb", "lib/warden/mixins/common.rb", "lib/warden/proxy.rb", "lib/warden/session_serializer.rb", "lib/warden/strategies.rb", "lib/warden/strategies/base.rb", "lib/warden/test/helpers.rb", "lib/warden/test/warden_helpers.rb", "lib/warden/version.rb", "script/destroy", "script/generate", "spec/helpers/request_helper.rb", "spec/helpers/strategies/failz.rb", "spec/helpers/strategies/invalid.rb", "spec/helpers/strategies/pass.rb", "spec/helpers/strategies/pass_with_message.rb", "spec/helpers/strategies/password.rb", "spec/spec_helper.rb", "spec/warden/authenticated_data_store_spec.rb", "spec/warden/config_spec.rb", "spec/warden/errors_spec.rb", "spec/warden/hooks_spec.rb", "spec/warden/manager_spec.rb", "spec/warden/proxy_spec.rb", "spec/warden/session_serializer_spec.rb", "spec/warden/strategies/base_spec.rb", "spec/warden/strategies_spec.rb", "spec/warden/test/helpers_spec.rb", "spec/warden/test/test_mode_spec.rb", "spec/warden_spec.rb", "warden.gemspec"]
  s.homepage = %q{http://github.com/hassox/warden}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{warden}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rack middleware that provides authentication for rack applications}
  s.test_files = ["spec/helpers/request_helper.rb", "spec/helpers/strategies/failz.rb", "spec/helpers/strategies/invalid.rb", "spec/helpers/strategies/pass.rb", "spec/helpers/strategies/pass_with_message.rb", "spec/helpers/strategies/password.rb", "spec/spec_helper.rb", "spec/warden/authenticated_data_store_spec.rb", "spec/warden/config_spec.rb", "spec/warden/errors_spec.rb", "spec/warden/hooks_spec.rb", "spec/warden/manager_spec.rb", "spec/warden/proxy_spec.rb", "spec/warden/session_serializer_spec.rb", "spec/warden/strategies/base_spec.rb", "spec/warden/strategies_spec.rb", "spec/warden/test/helpers_spec.rb", "spec/warden/test/test_mode_spec.rb", "spec/warden_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_development_dependency(%q<rspec>, [">= 1.0.0"])
    else
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<rspec>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<rspec>, [">= 1.0.0"])
  end
end
