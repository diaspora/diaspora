# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{culerity}
  s.version = "0.2.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alexander Lang"]
  s.date = %q{2011-01-21}
  s.default_executable = %q{run_celerity_server.rb}
  s.description = %q{Culerity integrates Cucumber and Celerity in order to test your application's full stack.}
  s.email = %q{alex@upstream-berlin.com}
  s.executables = ["run_celerity_server.rb"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["CHANGES.md", "MIT-LICENSE", "README.md", "Rakefile", "VERSION.yml", "bin/run_celerity_server.rb", "culerity.gemspec", "features/fixtures/jquery", "features/fixtures/sample_feature", "features/installing_culerity.feature", "features/running_cucumber_without_explicitly_running_external_services.feature", "features/step_definitions/common_steps.rb", "features/step_definitions/culerity_setup_steps.rb", "features/step_definitions/jruby_steps.rb", "features/step_definitions/rails_setup_steps.rb", "features/support/common.rb", "features/support/env.rb", "features/support/matchers.rb", "init.rb", "lib/culerity.rb", "lib/culerity/celerity_server.rb", "lib/culerity/persistent_delivery.rb", "lib/culerity/remote_browser_proxy.rb", "lib/culerity/remote_object_proxy.rb", "lib/start_celerity.rb", "lib/tasks/rspec.rake", "rails/init.rb", "rails_generators/culerity/culerity_generator.rb", "rails_generators/culerity/templates/config/environments/culerity.rb", "rails_generators/culerity/templates/config/environments/culerity_continuousintegration.rb", "rails_generators/culerity/templates/features/step_definitions/culerity_steps.rb", "rails_generators/culerity/templates/features/support/env.rb", "rails_generators/culerity/templates/lib/tasks/culerity.rake", "rails_generators/culerity/templates/public/javascripts/culerity.js", "script/console", "script/destroy", "script/generate", "spec/celerity_server_spec.rb", "spec/culerity_spec.rb", "spec/remote_browser_proxy_spec.rb", "spec/remote_object_proxy_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/langalex/culerity}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Culerity integrates Cucumber and Celerity in order to test your application's full stack.}
  s.test_files = ["spec/celerity_server_spec.rb", "spec/culerity_spec.rb", "spec/remote_browser_proxy_spec.rb", "spec/remote_object_proxy_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
