# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{database_cleaner}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Mabey"]
  s.date = %q{2010-10-25}
  s.description = %q{Strategies for cleaning databases.  Can be used to ensure a clean state for testing.}
  s.email = %q{ben@benmabey.com}
  s.extra_rdoc_files = ["LICENSE", "README.textile", "TODO"]
  s.files = ["Gemfile.lock", "History.txt", "README.textile", "Rakefile", "VERSION.yml", "cucumber.yml", "examples/Gemfile", "examples/Gemfile.lock", "examples/config/database.yml.example", "examples/db/sqlite_databases_go_here", "examples/features/example.feature", "examples/features/example_multiple_db.feature", "examples/features/example_multiple_orm.feature", "examples/features/step_definitions/activerecord_steps.rb", "examples/features/step_definitions/couchpotato_steps.rb", "examples/features/step_definitions/datamapper_steps.rb", "examples/features/step_definitions/mongoid_steps.rb", "examples/features/step_definitions/mongomapper_steps.rb", "examples/features/step_definitions/translation_steps.rb", "examples/features/support/env.rb", "examples/lib/activerecord_models.rb", "examples/lib/couchpotato_models.rb", "examples/lib/datamapper_models.rb", "examples/lib/mongoid_models.rb", "examples/lib/mongomapper_models.rb", "features/cleaning.feature", "features/cleaning_multiple_dbs.feature", "features/cleaning_multiple_orms.feature", "features/step_definitions/database_cleaner_steps.rb", "features/support/env.rb", "features/support/feature_runner.rb", "lib/database_cleaner.rb", "lib/database_cleaner/active_record/base.rb", "lib/database_cleaner/active_record/deletion.rb", "lib/database_cleaner/active_record/transaction.rb", "lib/database_cleaner/active_record/truncation.rb", "lib/database_cleaner/base.rb", "lib/database_cleaner/configuration.rb", "lib/database_cleaner/couch_potato/base.rb", "lib/database_cleaner/couch_potato/truncation.rb", "lib/database_cleaner/cucumber.rb", "lib/database_cleaner/data_mapper/base.rb", "lib/database_cleaner/data_mapper/transaction.rb", "lib/database_cleaner/data_mapper/truncation.rb", "lib/database_cleaner/generic/base.rb", "lib/database_cleaner/generic/truncation.rb", "lib/database_cleaner/mongo_mapper/base.rb", "lib/database_cleaner/mongo_mapper/truncation.rb", "lib/database_cleaner/mongoid/base.rb", "lib/database_cleaner/mongoid/truncation.rb", "spec/database_cleaner/active_record/base_spec.rb", "spec/database_cleaner/active_record/transaction_spec.rb", "spec/database_cleaner/active_record/truncation_spec.rb", "spec/database_cleaner/base_spec.rb", "spec/database_cleaner/configuration_spec.rb", "spec/database_cleaner/couch_potato/truncation_spec.rb", "spec/database_cleaner/data_mapper/base_spec.rb", "spec/database_cleaner/data_mapper/transaction_spec.rb", "spec/database_cleaner/data_mapper/truncation_spec.rb", "spec/database_cleaner/generic/base_spec.rb", "spec/database_cleaner/generic/truncation_spec.rb", "spec/database_cleaner/mongo_mapper/base_spec.rb", "spec/database_cleaner/mongo_mapper/mongo_examples.rb", "spec/database_cleaner/mongo_mapper/truncation_spec.rb", "spec/database_cleaner/mongoid/truncation_spec.rb", "spec/database_cleaner/shared_strategy_spec.rb", "spec/rcov.opts", "spec/spec.opts", "spec/spec_helper.rb", "LICENSE", "TODO"]
  s.homepage = %q{http://github.com/bmabey/database_cleaner}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Strategies for cleaning databases.  Can be used to ensure a clean state for testing.}
  s.test_files = ["spec/database_cleaner/active_record/base_spec.rb", "spec/database_cleaner/active_record/transaction_spec.rb", "spec/database_cleaner/active_record/truncation_spec.rb", "spec/database_cleaner/base_spec.rb", "spec/database_cleaner/configuration_spec.rb", "spec/database_cleaner/couch_potato/truncation_spec.rb", "spec/database_cleaner/data_mapper/base_spec.rb", "spec/database_cleaner/data_mapper/transaction_spec.rb", "spec/database_cleaner/data_mapper/truncation_spec.rb", "spec/database_cleaner/generic/base_spec.rb", "spec/database_cleaner/generic/truncation_spec.rb", "spec/database_cleaner/mongo_mapper/base_spec.rb", "spec/database_cleaner/mongo_mapper/mongo_examples.rb", "spec/database_cleaner/mongo_mapper/truncation_spec.rb", "spec/database_cleaner/mongoid/truncation_spec.rb", "spec/database_cleaner/shared_strategy_spec.rb", "spec/spec_helper.rb", "examples/features/step_definitions/activerecord_steps.rb", "examples/features/step_definitions/couchpotato_steps.rb", "examples/features/step_definitions/datamapper_steps.rb", "examples/features/step_definitions/mongoid_steps.rb", "examples/features/step_definitions/mongomapper_steps.rb", "examples/features/step_definitions/translation_steps.rb", "examples/features/support/env.rb", "examples/lib/activerecord_models.rb", "examples/lib/couchpotato_models.rb", "examples/lib/datamapper_models.rb", "examples/lib/mongoid_models.rb", "examples/lib/mongomapper_models.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
