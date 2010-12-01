# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{term-ansicolor}
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = %q{2010-03-12}
  s.description = %q{}
  s.email = %q{flori@ping.de}
  s.executables = ["cdiff", "decolor"]
  s.extra_rdoc_files = ["README"]
  s.files = ["CHANGES", "COPYING", "README", "Rakefile", "VERSION", "bin/cdiff", "bin/decolor", "examples/example.rb", "install.rb", "lib/term/ansicolor.rb", "lib/term/ansicolor/version.rb", "tests/ansicolor_test.rb"]
  s.homepage = %q{http://flori.github.com/term-ansicolor}
  s.rdoc_options = ["--main", "README", "--title", "Term::ANSIColor"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{term-ansicolor}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby library that colors strings using ANSI escape sequences}
  s.test_files = ["tests/ansicolor_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
