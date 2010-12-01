# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongo}
  s.version = "1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Menard", "Mike Dirolf", "Kyle Banker"]
  s.date = %q{2010-10-04}
  s.default_executable = %q{mongo_console}
  s.description = %q{A Ruby driver for MongoDB. For more information about Mongo, see http://www.mongodb.org.}
  s.email = %q{mongodb-dev@googlegroups.com}
  s.executables = ["mongo_console"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "HISTORY", "Rakefile", "mongo.gemspec", "LICENSE.txt", "lib/mongo.rb", "lib/mongo/collection.rb", "lib/mongo/connection.rb", "lib/mongo/cursor.rb", "lib/mongo/db.rb", "lib/mongo/exceptions.rb", "lib/mongo/gridfs/grid.rb", "lib/mongo/gridfs/grid_ext.rb", "lib/mongo/gridfs/grid_file_system.rb", "lib/mongo/gridfs/grid_io.rb", "lib/mongo/util/conversions.rb", "lib/mongo/util/core_ext.rb", "lib/mongo/util/server_version.rb", "lib/mongo/util/support.rb", "examples/admin.rb", "examples/capped.rb", "examples/cursor.rb", "examples/gridfs.rb", "examples/index_test.rb", "examples/info.rb", "examples/queries.rb", "examples/simple.rb", "examples/strict.rb", "examples/types.rb", "bin/bson_benchmark.rb", "bin/fail_if_no_c.rb", "bin/insert.rb", "bin/oid.rb", "bin/mongo_console", "test/collection_test.rb", "test/connection_test.rb", "test/conversions_test.rb", "test/cursor_fail_test.rb", "test/cursor_message_test.rb", "test/cursor_test.rb", "test/db_api_test.rb", "test/db_connection_test.rb", "test/db_test.rb", "test/grid_file_system_test.rb", "test/grid_io_test.rb", "test/grid_test.rb", "test/support_test.rb", "test/test_helper.rb", "test/threading_test.rb", "test/auxillary/1.4_features.rb", "test/auxillary/authentication_test.rb", "test/auxillary/autoreconnect_test.rb", "test/auxillary/slave_connection_test.rb", "test/bson/basic_test.rb", "test/bson/bench_test.rb", "test/bson/binary_test.rb", "test/bson/bson_test.rb", "test/bson/byte_buffer_test.rb", "test/bson/c_encode_test.rb", "test/bson/java_bson_test.rb", "test/bson/jruby_bson_test.rb", "test/bson/jruby_encode_test.rb", "test/bson/json_test.rb", "test/bson/object_id_test.rb", "test/bson/ordered_hash_test.rb", "test/replica_pairs/count_test.rb", "test/replica_pairs/insert_test.rb", "test/replica_pairs/pooled_insert_test.rb", "test/replica_pairs/query_test.rb", "test/replica_sets/count_test.rb", "test/replica_sets/insert_test.rb", "test/replica_sets/node_type_test.rb", "test/replica_sets/pooled_insert_test.rb", "test/replica_sets/query_test.rb", "test/replica_sets/replication_ack_test.rb", "test/threading/test_threading_large_pool.rb", "test/unit/collection_test.rb", "test/unit/connection_test.rb", "test/unit/cursor_test.rb", "test/unit/db_test.rb"]
  s.homepage = %q{http://www.mongodb.org}
  s.rdoc_options = ["--main", "README.rdoc", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby driver for the MongoDB}
  s.test_files = ["test/collection_test.rb", "test/connection_test.rb", "test/conversions_test.rb", "test/cursor_fail_test.rb", "test/cursor_message_test.rb", "test/cursor_test.rb", "test/db_api_test.rb", "test/db_connection_test.rb", "test/db_test.rb", "test/grid_file_system_test.rb", "test/grid_io_test.rb", "test/grid_test.rb", "test/support_test.rb", "test/test_helper.rb", "test/threading_test.rb", "test/auxillary/1.4_features.rb", "test/auxillary/authentication_test.rb", "test/auxillary/autoreconnect_test.rb", "test/auxillary/slave_connection_test.rb", "test/bson/basic_test.rb", "test/bson/bench_test.rb", "test/bson/binary_test.rb", "test/bson/bson_test.rb", "test/bson/byte_buffer_test.rb", "test/bson/c_encode_test.rb", "test/bson/java_bson_test.rb", "test/bson/jruby_bson_test.rb", "test/bson/jruby_encode_test.rb", "test/bson/json_test.rb", "test/bson/object_id_test.rb", "test/bson/ordered_hash_test.rb", "test/replica_pairs/count_test.rb", "test/replica_pairs/insert_test.rb", "test/replica_pairs/pooled_insert_test.rb", "test/replica_pairs/query_test.rb", "test/replica_sets/count_test.rb", "test/replica_sets/insert_test.rb", "test/replica_sets/node_type_test.rb", "test/replica_sets/pooled_insert_test.rb", "test/replica_sets/query_test.rb", "test/replica_sets/replication_ack_test.rb", "test/threading/test_threading_large_pool.rb", "test/unit/collection_test.rb", "test/unit/connection_test.rb", "test/unit/cursor_test.rb", "test/unit/db_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bson>, [">= 1.0.5"])
    else
      s.add_dependency(%q<bson>, [">= 1.0.5"])
    end
  else
    s.add_dependency(%q<bson>, [">= 1.0.5"])
  end
end
