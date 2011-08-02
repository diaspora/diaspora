# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activerecord-import}
  s.version = "0.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zach Dennis"]
  s.date = %q{2011-04-29}
  s.description = %q{Extraction of the ActiveRecord::Base#import functionality from ar-extensions for Rails 3 and beyond}
  s.email = %q{zach.dennis@gmail.com}
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown", "Rakefile", "VERSION", "lib/activerecord-import.rb", "lib/activerecord-import/active_record/adapters/abstract_adapter.rb", "lib/activerecord-import/active_record/adapters/mysql2_adapter.rb", "lib/activerecord-import/active_record/adapters/mysql_adapter.rb", "lib/activerecord-import/active_record/adapters/postgresql_adapter.rb", "lib/activerecord-import/active_record/adapters/sqlite3_adapter.rb", "lib/activerecord-import/adapters/abstract_adapter.rb", "lib/activerecord-import/adapters/mysql_adapter.rb", "lib/activerecord-import/adapters/postgresql_adapter.rb", "lib/activerecord-import/adapters/sqlite3_adapter.rb", "lib/activerecord-import/base.rb", "lib/activerecord-import/import.rb", "lib/activerecord-import/mysql.rb", "lib/activerecord-import/mysql2.rb", "lib/activerecord-import/postgresql.rb", "lib/activerecord-import/sqlite3.rb", "lib/activerecord-import/synchronize.rb", "test/active_record/connection_adapter_test.rb", "test/adapters/mysql.rb", "test/adapters/mysql2.rb", "test/adapters/postgresql.rb", "test/adapters/sqlite3.rb", "test/import_test.rb", "test/models/book.rb", "test/models/group.rb", "test/models/topic.rb", "test/mysql/import_test.rb", "test/mysql2/import_test.rb", "test/postgresql/import_test.rb", "test/schema/generic_schema.rb", "test/schema/mysql_schema.rb", "test/schema/version.rb", "test/support/active_support/test_case_extensions.rb", "test/support/factories.rb", "test/support/generate.rb", "test/support/mysql/assertions.rb", "test/support/mysql/import_examples.rb", "test/synchronize_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/zdennis/activerecord-import}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Bulk-loading extension for ActiveRecord}
  s.test_files = ["test/active_record/connection_adapter_test.rb", "test/adapters/mysql.rb", "test/adapters/mysql2.rb", "test/adapters/postgresql.rb", "test/adapters/sqlite3.rb", "test/import_test.rb", "test/models/book.rb", "test/models/group.rb", "test/models/topic.rb", "test/mysql/import_test.rb", "test/mysql2/import_test.rb", "test/postgresql/import_test.rb", "test/schema/generic_schema.rb", "test/schema/mysql_schema.rb", "test/schema/version.rb", "test/support/active_support/test_case_extensions.rb", "test/support/factories.rb", "test/support/generate.rb", "test/support/mysql/assertions.rb", "test/support/mysql/import_examples.rb", "test/synchronize_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["~> 3.0.0"])
    else
      s.add_dependency(%q<activerecord>, ["~> 3.0.0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["~> 3.0.0"])
  end
end
