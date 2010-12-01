# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{linecache}
  s.version = "0.43"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["R. Bernstein"]
  s.cert_chain = nil
  s.date = %q{2008-06-12}
  s.description = %q{LineCache is a module for reading and caching lines. This may be useful for example in a debugger where the same lines are shown many times.}
  s.email = %q{rockyb@rubyforge.net}
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["README", "lib/linecache.rb", "lib/tracelines.rb"]
  s.files = ["AUTHORS", "COPYING", "ChangeLog", "NEWS", "README", "Rakefile", "VERSION", "ext/trace_nums.c", "ext/trace_nums.h", "ext/extconf.rb", "lib/tracelines.rb", "lib/linecache.rb", "test/rcov-bug.rb", "test/test-tracelines.rb", "test/test-lnum.rb", "test/test-linecache.rb", "test/parse-show.rb", "test/lnum-diag.rb", "test/data/for1.rb", "test/data/if6.rb", "test/data/comments1.rb", "test/data/if3.rb", "test/data/if5.rb", "test/data/begin3.rb", "test/data/end.rb", "test/data/case1.rb", "test/data/match.rb", "test/data/begin2.rb", "test/data/match3.rb", "test/data/case5.rb", "test/data/not-lit.rb", "test/data/match3a.rb", "test/data/if7.rb", "test/data/if4.rb", "test/data/case2.rb", "test/data/block2.rb", "test/data/begin1.rb", "test/data/def1.rb", "test/data/if1.rb", "test/data/class1.rb", "test/data/if2.rb", "test/data/block1.rb", "test/data/case3.rb", "test/data/each1.rb", "test/data/case4.rb", "test/short-file"]
  s.homepage = %q{http://rubyforge.org/projects/rocky-hacks/linecache}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.rubyforge_project = %q{rocky-hacks}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Read file with caching}
  s.test_files = ["test/rcov-bug.rb", "test/test-tracelines.rb", "test/test-lnum.rb", "test/test-linecache.rb", "test/parse-show.rb", "test/lnum-diag.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
