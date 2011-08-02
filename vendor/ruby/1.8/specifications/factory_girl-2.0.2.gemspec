# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{factory_girl}
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joe Ferris"]
  s.date = %q{2011-07-28}
  s.description = %q{factory_girl provides a framework and DSL for defining and
                       using factories - less error-prone, more explicit, and
                       all-around easier to work with than fixtures.}
  s.email = %q{jferris@thoughtbot.com}
  s.files = ["Appraisals", "Changelog", "CONTRIBUTION_GUIDELINES.md", "Gemfile", "Gemfile.lock", "GETTING_STARTED.md", "LICENSE", "Rakefile", "README.md", "lib/factory_girl/aliases.rb", "lib/factory_girl/attribute/association.rb", "lib/factory_girl/attribute/callback.rb", "lib/factory_girl/attribute/dynamic.rb", "lib/factory_girl/attribute/implicit.rb", "lib/factory_girl/attribute/sequence.rb", "lib/factory_girl/attribute/static.rb", "lib/factory_girl/attribute.rb", "lib/factory_girl/definition_proxy.rb", "lib/factory_girl/deprecated.rb", "lib/factory_girl/factory.rb", "lib/factory_girl/find_definitions.rb", "lib/factory_girl/proxy/attributes_for.rb", "lib/factory_girl/proxy/build.rb", "lib/factory_girl/proxy/create.rb", "lib/factory_girl/proxy/stub.rb", "lib/factory_girl/proxy.rb", "lib/factory_girl/rails2.rb", "lib/factory_girl/registry.rb", "lib/factory_girl/sequence.rb", "lib/factory_girl/step_definitions.rb", "lib/factory_girl/syntax/blueprint.rb", "lib/factory_girl/syntax/default.rb", "lib/factory_girl/syntax/generate.rb", "lib/factory_girl/syntax/make.rb", "lib/factory_girl/syntax/methods.rb", "lib/factory_girl/syntax/sham.rb", "lib/factory_girl/syntax/vintage.rb", "lib/factory_girl/syntax.rb", "lib/factory_girl/version.rb", "lib/factory_girl.rb", "spec/acceptance/acceptance_helper.rb", "spec/acceptance/attribute_aliases_spec.rb", "spec/acceptance/attributes_for_spec.rb", "spec/acceptance/build_list_spec.rb", "spec/acceptance/build_spec.rb", "spec/acceptance/build_stubbed_spec.rb", "spec/acceptance/callbacks_spec.rb", "spec/acceptance/create_list_spec.rb", "spec/acceptance/create_spec.rb", "spec/acceptance/default_strategy_spec.rb", "spec/acceptance/definition_spec.rb", "spec/acceptance/definition_without_block_spec.rb", "spec/acceptance/parent_spec.rb", "spec/acceptance/sequence_spec.rb", "spec/acceptance/syntax/blueprint_spec.rb", "spec/acceptance/syntax/generate_spec.rb", "spec/acceptance/syntax/make_spec.rb", "spec/acceptance/syntax/sham_spec.rb", "spec/acceptance/syntax/vintage_spec.rb", "spec/factory_girl/aliases_spec.rb", "spec/factory_girl/attribute/association_spec.rb", "spec/factory_girl/attribute/callback_spec.rb", "spec/factory_girl/attribute/dynamic_spec.rb", "spec/factory_girl/attribute/implicit_spec.rb", "spec/factory_girl/attribute/sequence_spec.rb", "spec/factory_girl/attribute/static_spec.rb", "spec/factory_girl/attribute_spec.rb", "spec/factory_girl/definition_proxy_spec.rb", "spec/factory_girl/deprecated_spec.rb", "spec/factory_girl/factory_spec.rb", "spec/factory_girl/find_definitions_spec.rb", "spec/factory_girl/proxy/attributes_for_spec.rb", "spec/factory_girl/proxy/build_spec.rb", "spec/factory_girl/proxy/create_spec.rb", "spec/factory_girl/proxy/stub_spec.rb", "spec/factory_girl/proxy_spec.rb", "spec/factory_girl/registry_spec.rb", "spec/factory_girl/sequence_spec.rb", "spec/factory_girl_spec.rb", "spec/spec_helper.rb", "features/factory_girl_steps.feature", "features/find_definitions.feature", "features/step_definitions/database_steps.rb", "features/step_definitions/factory_girl_steps.rb", "features/support/env.rb", "features/support/factories.rb", "features/support/test.db"]
  s.homepage = %q{https://github.com/thoughtbot/factory_girl}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{factory_girl provides a framework and DSL for defining and using model instance factories.}
  s.test_files = ["spec/acceptance/attribute_aliases_spec.rb", "spec/acceptance/attributes_for_spec.rb", "spec/acceptance/build_list_spec.rb", "spec/acceptance/build_spec.rb", "spec/acceptance/build_stubbed_spec.rb", "spec/acceptance/callbacks_spec.rb", "spec/acceptance/create_list_spec.rb", "spec/acceptance/create_spec.rb", "spec/acceptance/default_strategy_spec.rb", "spec/acceptance/definition_spec.rb", "spec/acceptance/definition_without_block_spec.rb", "spec/acceptance/parent_spec.rb", "spec/acceptance/sequence_spec.rb", "spec/acceptance/syntax/blueprint_spec.rb", "spec/acceptance/syntax/generate_spec.rb", "spec/acceptance/syntax/make_spec.rb", "spec/acceptance/syntax/sham_spec.rb", "spec/acceptance/syntax/vintage_spec.rb", "spec/factory_girl/aliases_spec.rb", "spec/factory_girl/attribute/association_spec.rb", "spec/factory_girl/attribute/callback_spec.rb", "spec/factory_girl/attribute/dynamic_spec.rb", "spec/factory_girl/attribute/implicit_spec.rb", "spec/factory_girl/attribute/sequence_spec.rb", "spec/factory_girl/attribute/static_spec.rb", "spec/factory_girl/attribute_spec.rb", "spec/factory_girl/definition_proxy_spec.rb", "spec/factory_girl/deprecated_spec.rb", "spec/factory_girl/factory_spec.rb", "spec/factory_girl/find_definitions_spec.rb", "spec/factory_girl/proxy/attributes_for_spec.rb", "spec/factory_girl/proxy/build_spec.rb", "spec/factory_girl/proxy/create_spec.rb", "spec/factory_girl/proxy/stub_spec.rb", "spec/factory_girl/proxy_spec.rb", "spec/factory_girl/registry_spec.rb", "spec/factory_girl/sequence_spec.rb", "spec/factory_girl_spec.rb", "features/factory_girl_steps.feature", "features/find_definitions.feature", "features/step_definitions/database_steps.rb", "features/step_definitions/factory_girl_steps.rb", "features/support/env.rb", "features/support/factories.rb", "features/support/test.db"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, ["~> 2.3.5"])
      s.add_development_dependency(%q<activerecord>, ["~> 3.0.0.beta3"])
      s.add_development_dependency(%q<rr>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<aruba>, [">= 0"])
    else
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<activerecord>, ["~> 2.3.5"])
      s.add_dependency(%q<activerecord>, ["~> 3.0.0.beta3"])
      s.add_dependency(%q<rr>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<aruba>, [">= 0"])
    end
  else
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<activerecord>, ["~> 2.3.5"])
    s.add_dependency(%q<activerecord>, ["~> 3.0.0.beta3"])
    s.add_dependency(%q<rr>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<aruba>, [">= 0"])
  end
end
