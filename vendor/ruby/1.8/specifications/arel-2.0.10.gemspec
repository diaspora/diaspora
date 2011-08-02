# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{arel}
  s.version = "2.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson", "Bryan Halmkamp", "Emilio Tagua", "Nick Kallen"]
  s.date = %q{2011-05-17}
  s.description = %q{Arel is a Relational Algebra for Ruby. It 1) simplifies the generation complex of SQL queries and it 2) adapts to various RDBMS systems. It is intended to be a framework framework; that is, you can build your own ORM with it, focusing on innovative object and collection modeling as opposed to database compatibility and query generation.}
  s.email = ["aaron@tenderlovemaking.com", "bryan@brynary.com", "miloops@gmail.com", "nick@example.org"]
  s.extra_rdoc_files = ["History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.markdown"]
  s.files = [".autotest", "History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.markdown", "Rakefile", "arel.gemspec", "lib/arel.rb", "lib/arel/attributes.rb", "lib/arel/attributes/attribute.rb", "lib/arel/compatibility/wheres.rb", "lib/arel/crud.rb", "lib/arel/delete_manager.rb", "lib/arel/deprecated.rb", "lib/arel/expression.rb", "lib/arel/expressions.rb", "lib/arel/insert_manager.rb", "lib/arel/nodes.rb", "lib/arel/nodes/and.rb", "lib/arel/nodes/as.rb", "lib/arel/nodes/assignment.rb", "lib/arel/nodes/avg.rb", "lib/arel/nodes/between.rb", "lib/arel/nodes/binary.rb", "lib/arel/nodes/count.rb", "lib/arel/nodes/delete_statement.rb", "lib/arel/nodes/does_not_match.rb", "lib/arel/nodes/equality.rb", "lib/arel/nodes/except.rb", "lib/arel/nodes/exists.rb", "lib/arel/nodes/function.rb", "lib/arel/nodes/greater_than.rb", "lib/arel/nodes/greater_than_or_equal.rb", "lib/arel/nodes/group.rb", "lib/arel/nodes/grouping.rb", "lib/arel/nodes/having.rb", "lib/arel/nodes/in.rb", "lib/arel/nodes/inner_join.rb", "lib/arel/nodes/insert_statement.rb", "lib/arel/nodes/intersect.rb", "lib/arel/nodes/join.rb", "lib/arel/nodes/less_than.rb", "lib/arel/nodes/less_than_or_equal.rb", "lib/arel/nodes/limit.rb", "lib/arel/nodes/lock.rb", "lib/arel/nodes/matches.rb", "lib/arel/nodes/max.rb", "lib/arel/nodes/min.rb", "lib/arel/nodes/node.rb", "lib/arel/nodes/not.rb", "lib/arel/nodes/not_equal.rb", "lib/arel/nodes/not_in.rb", "lib/arel/nodes/offset.rb", "lib/arel/nodes/on.rb", "lib/arel/nodes/or.rb", "lib/arel/nodes/ordering.rb", "lib/arel/nodes/outer_join.rb", "lib/arel/nodes/select_core.rb", "lib/arel/nodes/select_statement.rb", "lib/arel/nodes/sql_literal.rb", "lib/arel/nodes/string_join.rb", "lib/arel/nodes/sum.rb", "lib/arel/nodes/table_alias.rb", "lib/arel/nodes/top.rb", "lib/arel/nodes/unary.rb", "lib/arel/nodes/union.rb", "lib/arel/nodes/union_all.rb", "lib/arel/nodes/unqualified_column.rb", "lib/arel/nodes/update_statement.rb", "lib/arel/nodes/values.rb", "lib/arel/predications.rb", "lib/arel/relation.rb", "lib/arel/select_manager.rb", "lib/arel/sql/engine.rb", "lib/arel/sql_literal.rb", "lib/arel/table.rb", "lib/arel/tree_manager.rb", "lib/arel/update_manager.rb", "lib/arel/visitors.rb", "lib/arel/visitors/depth_first.rb", "lib/arel/visitors/dot.rb", "lib/arel/visitors/join_sql.rb", "lib/arel/visitors/mssql.rb", "lib/arel/visitors/mysql.rb", "lib/arel/visitors/oracle.rb", "lib/arel/visitors/order_clauses.rb", "lib/arel/visitors/postgresql.rb", "lib/arel/visitors/sqlite.rb", "lib/arel/visitors/to_sql.rb", "lib/arel/visitors/visitor.rb", "lib/arel/visitors/where_sql.rb", "test/attributes/test_attribute.rb", "test/helper.rb", "test/nodes/test_as.rb", "test/nodes/test_count.rb", "test/nodes/test_delete_statement.rb", "test/nodes/test_equality.rb", "test/nodes/test_insert_statement.rb", "test/nodes/test_node.rb", "test/nodes/test_not.rb", "test/nodes/test_or.rb", "test/nodes/test_select_core.rb", "test/nodes/test_select_statement.rb", "test/nodes/test_sql_literal.rb", "test/nodes/test_sum.rb", "test/nodes/test_update_statement.rb", "test/support/fake_record.rb", "test/test_activerecord_compat.rb", "test/test_attributes.rb", "test/test_crud.rb", "test/test_delete_manager.rb", "test/test_insert_manager.rb", "test/test_select_manager.rb", "test/test_table.rb", "test/test_update_manager.rb", "test/visitors/test_depth_first.rb", "test/visitors/test_dot.rb", "test/visitors/test_join_sql.rb", "test/visitors/test_mssql.rb", "test/visitors/test_mysql.rb", "test/visitors/test_oracle.rb", "test/visitors/test_postgres.rb", "test/visitors/test_sqlite.rb", "test/visitors/test_to_sql.rb", ".gemtest"]
  s.homepage = %q{http://github.com/rails/arel}
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{arel}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Arel is a Relational Algebra for Ruby}
  s.test_files = ["test/attributes/test_attribute.rb", "test/nodes/test_as.rb", "test/nodes/test_count.rb", "test/nodes/test_delete_statement.rb", "test/nodes/test_equality.rb", "test/nodes/test_insert_statement.rb", "test/nodes/test_node.rb", "test/nodes/test_not.rb", "test/nodes/test_or.rb", "test/nodes/test_select_core.rb", "test/nodes/test_select_statement.rb", "test/nodes/test_sql_literal.rb", "test/nodes/test_sum.rb", "test/nodes/test_update_statement.rb", "test/test_activerecord_compat.rb", "test/test_attributes.rb", "test/test_crud.rb", "test/test_delete_manager.rb", "test/test_insert_manager.rb", "test/test_select_manager.rb", "test/test_table.rb", "test/test_update_manager.rb", "test/visitors/test_depth_first.rb", "test/visitors/test_dot.rb", "test/visitors/test_join_sql.rb", "test/visitors/test_mssql.rb", "test/visitors/test_mysql.rb", "test/visitors/test_oracle.rb", "test/visitors/test_postgres.rb", "test/visitors/test_sqlite.rb", "test/visitors/test_to_sql.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, [">= 2.0.2"])
      s.add_development_dependency(%q<hoe>, [">= 2.1.0"])
      s.add_development_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_development_dependency(%q<hoe>, [">= 2.9.1"])
    else
      s.add_dependency(%q<minitest>, [">= 2.0.2"])
      s.add_dependency(%q<hoe>, [">= 2.1.0"])
      s.add_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_dependency(%q<hoe>, [">= 2.9.1"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 2.0.2"])
    s.add_dependency(%q<hoe>, [">= 2.1.0"])
    s.add_dependency(%q<minitest>, [">= 1.6.0"])
    s.add_dependency(%q<hoe>, [">= 2.9.1"])
  end
end
