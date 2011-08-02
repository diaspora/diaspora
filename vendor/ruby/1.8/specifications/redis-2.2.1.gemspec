# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{redis}
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ezra Zygmuntowicz", "Taylor Weibley", "Matthew Clark", "Brian McKinney", "Salvatore Sanfilippo", "Luca Guidi", "Michel Martens", "Damian Janowski", "Pieter Noordhuis"]
  s.autorequire = %q{redis}
  s.date = %q{2011-06-08}
  s.description = %q{Ruby client library for Redis, the key value storage server}
  s.email = %q{ez@engineyard.com}
  s.files = [".gitignore", "CHANGELOG.md", "LICENSE", "README.md", "Rakefile", "TODO.md", "benchmarking/logging.rb", "benchmarking/pipeline.rb", "benchmarking/speed.rb", "benchmarking/suite.rb", "benchmarking/thread_safety.rb", "benchmarking/worker.rb", "examples/basic.rb", "examples/dist_redis.rb", "examples/incr-decr.rb", "examples/list.rb", "examples/pubsub.rb", "examples/sets.rb", "examples/unicorn/config.ru", "examples/unicorn/unicorn.rb", "lib/redis.rb", "lib/redis/client.rb", "lib/redis/compat.rb", "lib/redis/connection.rb", "lib/redis/connection/command_helper.rb", "lib/redis/connection/hiredis.rb", "lib/redis/connection/registry.rb", "lib/redis/connection/ruby.rb", "lib/redis/connection/synchrony.rb", "lib/redis/distributed.rb", "lib/redis/hash_ring.rb", "lib/redis/pipeline.rb", "lib/redis/subscribe.rb", "lib/redis/version.rb", "redis.gemspec", "test/commands_on_hashes_test.rb", "test/commands_on_lists_test.rb", "test/commands_on_sets_test.rb", "test/commands_on_sorted_sets_test.rb", "test/commands_on_strings_test.rb", "test/commands_on_value_types_test.rb", "test/connection_handling_test.rb", "test/db/.gitignore", "test/distributed_blocking_commands_test.rb", "test/distributed_commands_on_hashes_test.rb", "test/distributed_commands_on_lists_test.rb", "test/distributed_commands_on_sets_test.rb", "test/distributed_commands_on_strings_test.rb", "test/distributed_commands_on_value_types_test.rb", "test/distributed_commands_requiring_clustering_test.rb", "test/distributed_connection_handling_test.rb", "test/distributed_internals_test.rb", "test/distributed_key_tags_test.rb", "test/distributed_persistence_control_commands_test.rb", "test/distributed_publish_subscribe_test.rb", "test/distributed_remote_server_control_commands_test.rb", "test/distributed_sorting_test.rb", "test/distributed_test.rb", "test/distributed_transactions_test.rb", "test/encoding_test.rb", "test/error_replies_test.rb", "test/helper.rb", "test/internals_test.rb", "test/lint/hashes.rb", "test/lint/internals.rb", "test/lint/lists.rb", "test/lint/sets.rb", "test/lint/sorted_sets.rb", "test/lint/strings.rb", "test/lint/value_types.rb", "test/persistence_control_commands_test.rb", "test/pipelining_commands_test.rb", "test/publish_subscribe_test.rb", "test/redis_mock.rb", "test/remote_server_control_commands_test.rb", "test/sorting_test.rb", "test/synchrony_driver.rb", "test/test.conf", "test/thread_safety_test.rb", "test/transactions_test.rb", "test/unknown_commands_test.rb", "test/url_param_test.rb"]
  s.homepage = %q{http://github.com/ezmobius/redis-rb}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{redis-rb}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby client library for Redis, the key value storage server}
  s.test_files = ["test/commands_on_hashes_test.rb", "test/commands_on_lists_test.rb", "test/commands_on_sets_test.rb", "test/commands_on_sorted_sets_test.rb", "test/commands_on_strings_test.rb", "test/commands_on_value_types_test.rb", "test/connection_handling_test.rb", "test/db/.gitignore", "test/distributed_blocking_commands_test.rb", "test/distributed_commands_on_hashes_test.rb", "test/distributed_commands_on_lists_test.rb", "test/distributed_commands_on_sets_test.rb", "test/distributed_commands_on_strings_test.rb", "test/distributed_commands_on_value_types_test.rb", "test/distributed_commands_requiring_clustering_test.rb", "test/distributed_connection_handling_test.rb", "test/distributed_internals_test.rb", "test/distributed_key_tags_test.rb", "test/distributed_persistence_control_commands_test.rb", "test/distributed_publish_subscribe_test.rb", "test/distributed_remote_server_control_commands_test.rb", "test/distributed_sorting_test.rb", "test/distributed_test.rb", "test/distributed_transactions_test.rb", "test/encoding_test.rb", "test/error_replies_test.rb", "test/helper.rb", "test/internals_test.rb", "test/lint/hashes.rb", "test/lint/internals.rb", "test/lint/lists.rb", "test/lint/sets.rb", "test/lint/sorted_sets.rb", "test/lint/strings.rb", "test/lint/value_types.rb", "test/persistence_control_commands_test.rb", "test/pipelining_commands_test.rb", "test/publish_subscribe_test.rb", "test/redis_mock.rb", "test/remote_server_control_commands_test.rb", "test/sorting_test.rb", "test/synchrony_driver.rb", "test/test.conf", "test/thread_safety_test.rb", "test/transactions_test.rb", "test/unknown_commands_test.rb", "test/url_param_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
