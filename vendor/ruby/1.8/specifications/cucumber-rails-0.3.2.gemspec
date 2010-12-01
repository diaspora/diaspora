# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cucumber-rails}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dennis Bl\303\266te", "Aslak Helles\303\270y", "Rob Holland"]
  s.date = %q{2010-06-06}
  s.description = %q{Cucumber Generators and Runtime for Rails}
  s.email = %q{cukes@googlegroups.com}
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = [".gitignore", "HACKING.rdoc", "History.txt", "LICENSE", "README.rdoc", "Rakefile", "VERSION", "config/.gitignore", "cucumber-rails.gemspec", "dev_tasks/cucumber.rake", "dev_tasks/rspec.rake", "features/rails2.feature", "features/rails3.feature", "features/rerun_profile.feature", "features/step_definitions/cucumber_rails_steps.rb", "features/support/env.rb", "features/support/matchers/files.rb", "generators/cucumber/USAGE", "generators/cucumber/cucumber_generator.rb", "generators/feature/USAGE", "generators/feature/feature_generator.rb", "lib/cucumber/rails/action_controller.rb", "lib/cucumber/rails/active_record.rb", "lib/cucumber/rails/capybara_javascript_emulation.rb", "lib/cucumber/rails/rspec.rb", "lib/cucumber/rails/test_unit.rb", "lib/cucumber/rails/world.rb", "lib/cucumber/web/tableish.rb", "lib/generators/cucumber/feature/USAGE", "lib/generators/cucumber/feature/feature_base.rb", "lib/generators/cucumber/feature/feature_generator.rb", "lib/generators/cucumber/feature/named_arg.rb", "lib/generators/cucumber/install/USAGE", "lib/generators/cucumber/install/install_base.rb", "lib/generators/cucumber/install/install_generator.rb", "spec/cucumber/web/tableish_spec.rb", "spec/generators/cucumber/install/install_base_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "templates/feature/feature.erb", "templates/feature/steps.erb", "templates/install/config/cucumber.yml.erb", "templates/install/environments/cucumber.rb.erb", "templates/install/script/cucumber", "templates/install/step_definitions/capybara_steps.rb.erb", "templates/install/step_definitions/web_steps_cs.rb.erb", "templates/install/step_definitions/web_steps_da.rb.erb", "templates/install/step_definitions/web_steps_de.rb.erb", "templates/install/step_definitions/web_steps_es.rb.erb", "templates/install/step_definitions/web_steps_ja.rb.erb", "templates/install/step_definitions/web_steps_ko.rb.erb", "templates/install/step_definitions/web_steps_no.rb.erb", "templates/install/step_definitions/web_steps_pt-BR.rb.erb", "templates/install/step_definitions/webrat_steps.rb.erb", "templates/install/support/_rails_each_run.rb.erb", "templates/install/support/_rails_prefork.rb.erb", "templates/install/support/capybara.rb", "templates/install/support/edit_warning.txt", "templates/install/support/paths.rb", "templates/install/support/rails.rb.erb", "templates/install/support/rails_spork.rb.erb", "templates/install/support/webrat.rb", "templates/install/tasks/cucumber.rake.erb"]
  s.homepage = %q{http://github.com/aslakhellesoy/cucumber-rails}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Cucumber Generators and Runtime for Rails}
  s.test_files = ["spec/cucumber/web/tableish_spec.rb", "spec/generators/cucumber/install/install_base_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cucumber>, [">= 0.8.0"])
      s.add_development_dependency(%q<aruba>, [">= 0.1.9"])
    else
      s.add_dependency(%q<cucumber>, [">= 0.8.0"])
      s.add_dependency(%q<aruba>, [">= 0.1.9"])
    end
  else
    s.add_dependency(%q<cucumber>, [">= 0.8.0"])
    s.add_dependency(%q<aruba>, [">= 0.1.9"])
  end
end
