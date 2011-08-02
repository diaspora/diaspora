# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{foreigner}
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Higgins"]
  s.date = %q{2010-10-23}
  s.description = %q{Adds helpers to migrations and correctly dumps foreign keys to schema.rb}
  s.email = %q{developer@matthewhiggins.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["MIT-LICENSE", "Rakefile", "README.rdoc", "lib/foreigner/connection_adapters/abstract/schema_definitions.rb", "lib/foreigner/connection_adapters/abstract/schema_statements.rb", "lib/foreigner/connection_adapters/mysql_adapter.rb", "lib/foreigner/connection_adapters/postgresql_adapter.rb", "lib/foreigner/connection_adapters/sql_2003.rb", "lib/foreigner/schema_dumper.rb", "lib/foreigner.rb", "test/helper.rb", "test/mysql_adapter_test.rb"]
  s.homepage = %q{http://github.com/matthuhiggins/foreigner}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubyforge_project = %q{foreigner}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Foreign keys for Rails}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
