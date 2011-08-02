# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jasmine}
  s.version = "1.0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rajan Agaskar", "Christian Williams", "Davis Frank"]
  s.date = %q{2011-05-16}
  s.default_executable = %q{jasmine}
  s.description = %q{Test your JavaScript without any framework dependencies, in any environment, and with a nice descriptive syntax.}
  s.email = %q{jasmine-js@googlegroups.com}
  s.executables = ["jasmine"]
  s.files = [".gitignore", ".gitmodules", "Gemfile", "HOW_TO_TEST.markdown", "MIT.LICENSE", "README.markdown", "RELEASE.markdown", "Rakefile", "bin/jasmine", "generators/jasmine/jasmine_generator.rb", "generators/jasmine/templates/INSTALL", "generators/jasmine/templates/jasmine-example/SpecRunner.html", "generators/jasmine/templates/jasmine-example/spec/PlayerSpec.js", "generators/jasmine/templates/jasmine-example/spec/SpecHelper.js", "generators/jasmine/templates/jasmine-example/src/Player.js", "generators/jasmine/templates/jasmine-example/src/Song.js", "generators/jasmine/templates/lib/tasks/jasmine.rake", "generators/jasmine/templates/spec/javascripts/support/jasmine-rails.yml", "generators/jasmine/templates/spec/javascripts/support/jasmine.yml", "generators/jasmine/templates/spec/javascripts/support/jasmine_config.rb", "generators/jasmine/templates/spec/javascripts/support/jasmine_runner.rb", "jasmine.gemspec", "lib/generators/jasmine/examples/USAGE", "lib/generators/jasmine/examples/examples_generator.rb", "lib/generators/jasmine/examples/templates/public/javascripts/jasmine_examples/Player.js", "lib/generators/jasmine/examples/templates/public/javascripts/jasmine_examples/Song.js", "lib/generators/jasmine/examples/templates/spec/javascripts/helpers/SpecHelper.js", "lib/generators/jasmine/examples/templates/spec/javascripts/jasmine_examples/PlayerSpec.js", "lib/generators/jasmine/install/USAGE", "lib/generators/jasmine/install/install_generator.rb", "lib/generators/jasmine/install/templates/spec/javascripts/helpers/.gitkeep", "lib/generators/jasmine/install/templates/spec/javascripts/support/jasmine.yml", "lib/generators/jasmine/install/templates/spec/javascripts/support/jasmine_config.rb", "lib/generators/jasmine/install/templates/spec/javascripts/support/jasmine_runner.rb", "lib/generators/jasmine/jasmine_generator.rb", "lib/generators/jasmine/templates/INSTALL", "lib/generators/jasmine/templates/lib/tasks/jasmine.rake", "lib/generators/jasmine/templates/spec/javascripts/support/jasmine-rails.yml", "lib/generators/jasmine/templates/spec/javascripts/support/jasmine.yml", "lib/generators/jasmine/templates/spec/javascripts/support/jasmine_config.rb", "lib/generators/jasmine/templates/spec/javascripts/support/jasmine_runner.rb", "lib/jasmine.rb", "lib/jasmine/base.rb", "lib/jasmine/command_line_tool.rb", "lib/jasmine/config.rb", "lib/jasmine/railtie.rb", "lib/jasmine/run.html.erb", "lib/jasmine/selenium_driver.rb", "lib/jasmine/server.rb", "lib/jasmine/spec_builder.rb", "lib/jasmine/tasks/jasmine.rake", "lib/jasmine/version.rb", "spec/config_spec.rb", "spec/fixture/jasmine.erb.yml", "spec/jasmine_command_line_tool_spec.rb", "spec/jasmine_pojs_spec.rb", "spec/jasmine_rails2_spec.rb", "spec/jasmine_rails3_spec.rb", "spec/jasmine_self_test_config.rb", "spec/jasmine_self_test_spec.rb", "spec/server_spec.rb", "spec/spec_helper.rb", "jasmine/cruise_config.rb", "jasmine/example/spec/PlayerSpec.js", "jasmine/example/spec/SpecHelper.js", "jasmine/example/SpecRunner.html", "jasmine/example/src/Player.js", "jasmine/example/src/Song.js", "jasmine/Gemfile", "jasmine/Gemfile.lock", "jasmine/HowToRelease.markdown", "jasmine/images/jasmine_favicon.png", "jasmine/jsdoc-template/allclasses.tmpl", "jasmine/jsdoc-template/allfiles.tmpl", "jasmine/jsdoc-template/class.tmpl", "jasmine/jsdoc-template/index.tmpl", "jasmine/jsdoc-template/publish.js", "jasmine/jsdoc-template/static/default.css", "jasmine/jsdoc-template/static/header.html", "jasmine/jsdoc-template/static/index.html", "jasmine/jsdoc-template/symbol.tmpl", "jasmine/jshint/jshint.js", "jasmine/jshint/run.js", "jasmine/lib/jasmine-html.js", "jasmine/lib/jasmine.css", "jasmine/lib/jasmine.js", "jasmine/lib/json2.js", "jasmine/MIT.LICENSE", "jasmine/Rakefile", "jasmine/README.markdown", "jasmine/spec/node_suite.js", "jasmine/spec/runner.html", "jasmine/spec/suites/BaseSpec.js", "jasmine/spec/suites/CustomMatchersSpec.js", "jasmine/spec/suites/EnvSpec.js", "jasmine/spec/suites/ExceptionsSpec.js", "jasmine/spec/suites/JsApiReporterSpec.js", "jasmine/spec/suites/MatchersSpec.js", "jasmine/spec/suites/MockClockSpec.js", "jasmine/spec/suites/MultiReporterSpec.js", "jasmine/spec/suites/NestedResultsSpec.js", "jasmine/spec/suites/PrettyPrintSpec.js", "jasmine/spec/suites/QueueSpec.js", "jasmine/spec/suites/ReporterSpec.js", "jasmine/spec/suites/RunnerSpec.js", "jasmine/spec/suites/SpecRunningSpec.js", "jasmine/spec/suites/SpecSpec.js", "jasmine/spec/suites/SpySpec.js", "jasmine/spec/suites/SuiteSpec.js", "jasmine/spec/suites/TrivialConsoleReporterSpec.js", "jasmine/spec/suites/TrivialReporterSpec.js", "jasmine/spec/suites/UtilSpec.js", "jasmine/spec/suites/WaitsForBlockSpec.js", "jasmine/src/base.js", "jasmine/src/Block.js", "jasmine/src/console/TrivialConsoleReporter.js", "jasmine/src/Env.js", "jasmine/src/html/jasmine.css", "jasmine/src/html/TrivialReporter.js", "jasmine/src/JsApiReporter.js", "jasmine/src/Matchers.js", "jasmine/src/mock-timeout.js", "jasmine/src/MultiReporter.js", "jasmine/src/NestedResults.js", "jasmine/src/PrettyPrinter.js", "jasmine/src/Queue.js", "jasmine/src/Reporter.js", "jasmine/src/Runner.js", "jasmine/src/Spec.js", "jasmine/src/Suite.js", "jasmine/src/util.js", "jasmine/src/version.json", "jasmine/src/WaitsBlock.js", "jasmine/src/WaitsForBlock.js"]
  s.homepage = %q{http://pivotal.github.com/jasmine}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{JavaScript BDD framework}
  s.test_files = ["spec/config_spec.rb", "spec/fixture/jasmine.erb.yml", "spec/jasmine_command_line_tool_spec.rb", "spec/jasmine_pojs_spec.rb", "spec/jasmine_rails2_spec.rb", "spec/jasmine_rails3_spec.rb", "spec/jasmine_self_test_config.rb", "spec/jasmine_self_test_spec.rb", "spec/server_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.5.0"])
      s.add_development_dependency(%q<rails>, [">= 3.0.3"])
      s.add_development_dependency(%q<rack>, [">= 1.2.1"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<gem-release>, [">= 0.0.16"])
      s.add_development_dependency(%q<ci_reporter>, [">= 0"])
      s.add_runtime_dependency(%q<rack>, [">= 1.1"])
      s.add_runtime_dependency(%q<rspec>, [">= 1.3.1"])
      s.add_runtime_dependency(%q<json_pure>, [">= 1.4.3"])
      s.add_runtime_dependency(%q<selenium-webdriver>, [">= 0.1.3"])
    else
      s.add_dependency(%q<rspec>, [">= 2.5.0"])
      s.add_dependency(%q<rails>, [">= 3.0.3"])
      s.add_dependency(%q<rack>, [">= 1.2.1"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<gem-release>, [">= 0.0.16"])
      s.add_dependency(%q<ci_reporter>, [">= 0"])
      s.add_dependency(%q<rack>, [">= 1.1"])
      s.add_dependency(%q<rspec>, [">= 1.3.1"])
      s.add_dependency(%q<json_pure>, [">= 1.4.3"])
      s.add_dependency(%q<selenium-webdriver>, [">= 0.1.3"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.5.0"])
    s.add_dependency(%q<rails>, [">= 3.0.3"])
    s.add_dependency(%q<rack>, [">= 1.2.1"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<gem-release>, [">= 0.0.16"])
    s.add_dependency(%q<ci_reporter>, [">= 0"])
    s.add_dependency(%q<rack>, [">= 1.1"])
    s.add_dependency(%q<rspec>, [">= 1.3.1"])
    s.add_dependency(%q<json_pure>, [">= 1.4.3"])
    s.add_dependency(%q<selenium-webdriver>, [">= 0.1.3"])
  end
end
