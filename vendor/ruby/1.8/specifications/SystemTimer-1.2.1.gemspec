# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{SystemTimer}
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philippe Hanrigou", "David Vollbracht"]
  s.autorequire = %q{system_timer}
  s.date = %q{2010-11-15}
  s.extensions = ["ext/system_timer/extconf.rb"]
  s.extra_rdoc_files = ["README"]
  s.files = ["COPYING", "LICENSE", "ChangeLog", "ext/system_timer/system_timer_native.c", "ext/system_timer/extconf.rb", "lib/system_timer/concurrent_timer_pool.rb", "lib/system_timer/thread_timer.rb", "lib/system_timer.rb", "lib/system_timer_stub.rb", "test/all_tests.rb", "test/system_timer/concurrent_timer_pool_unit_test.rb", "test/system_timer/thread_timer_test.rb", "test/system_timer_functional_test.rb", "test/system_timer_unit_test.rb", "test/test_helper.rb", "README"]
  s.rdoc_options = ["--title", "SystemTimer", "--main", "README", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{systemtimer}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Set a Timeout based on signals, which are more reliable than Timeout. Timeout is based on green threads.}
  s.test_files = ["test/all_tests.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
