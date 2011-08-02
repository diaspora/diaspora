# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mysql2}
  s.version = "0.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez"]
  s.date = %q{2010-10-19}
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/mysql2/extconf.rb"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = [".gitignore", ".rspec", "CHANGELOG.md", "MIT-LICENSE", "README.rdoc", "Rakefile", "VERSION", "benchmark/active_record.rb", "benchmark/allocations.rb", "benchmark/escape.rb", "benchmark/query_with_mysql_casting.rb", "benchmark/query_without_mysql_casting.rb", "benchmark/sequel.rb", "benchmark/setup_db.rb", "examples/eventmachine.rb", "examples/threaded.rb", "ext/mysql2/client.c", "ext/mysql2/client.h", "ext/mysql2/extconf.rb", "ext/mysql2/mysql2_ext.c", "ext/mysql2/mysql2_ext.h", "ext/mysql2/result.c", "ext/mysql2/result.h", "lib/active_record/connection_adapters/em_mysql2_adapter.rb", "lib/active_record/connection_adapters/mysql2_adapter.rb", "lib/active_record/fiber_patches.rb", "lib/arel/engines/sql/compilers/mysql2_compiler.rb", "lib/mysql2.rb", "lib/mysql2/client.rb", "lib/mysql2/em.rb", "lib/mysql2/error.rb", "lib/mysql2/result.rb", "mysql2.gemspec", "spec/em/em_spec.rb", "spec/mysql2/client_spec.rb", "spec/mysql2/error_spec.rb", "spec/mysql2/result_spec.rb", "spec/rcov.opts", "spec/spec_helper.rb", "tasks/benchmarks.rake", "tasks/compile.rake", "tasks/jeweler.rake", "tasks/rspec.rake", "tasks/vendor_mysql.rake"]
  s.homepage = %q{http://github.com/brianmario/mysql2}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A simple, fast Mysql library for Ruby, binding to libmysql}
  s.test_files = ["spec/em/em_spec.rb", "spec/mysql2/client_spec.rb", "spec/mysql2/error_spec.rb", "spec/mysql2/result_spec.rb", "spec/spec_helper.rb", "examples/eventmachine.rb", "examples/threaded.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
