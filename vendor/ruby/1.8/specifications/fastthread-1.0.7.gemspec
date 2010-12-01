# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fastthread}
  s.version = "1.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["MenTaLguY <mental@rydia.net>"]
  s.date = %q{2009-04-08}
  s.description = %q{Optimized replacement for thread.rb primitives}
  s.email = %q{mental@rydia.net}
  s.extensions = ["ext/fastthread/extconf.rb"]
  s.extra_rdoc_files = ["ext/fastthread/fastthread.c", "ext/fastthread/extconf.rb", "CHANGELOG"]
  s.files = ["test/test_queue.rb", "test/test_mutex.rb", "test/test_condvar.rb", "test/test_all.rb", "setup.rb", "Manifest", "ext/fastthread/fastthread.c", "ext/fastthread/extconf.rb", "CHANGELOG", "fastthread.gemspec", "Rakefile"]
  s.homepage = %q{}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Fastthread"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{mongrel}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Optimized replacement for thread.rb primitives}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
