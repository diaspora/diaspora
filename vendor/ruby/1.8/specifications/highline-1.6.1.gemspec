# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{highline}
  s.version = "1.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Edward Gray II"]
  s.date = %q{2010-07-15}
  s.description = %q{A high-level IO library that provides validation, type conversion, and more for
command-line interfaces. HighLine also includes a complete menu system that can
crank out anything from simple list selection to complete shells with just
minutes of work.
}
  s.email = %q{james@grayproductions.net}
  s.extra_rdoc_files = ["README", "INSTALL", "TODO", "CHANGELOG", "LICENSE"]
  s.files = ["examples/ansi_colors.rb", "examples/asking_for_arrays.rb", "examples/basic_usage.rb", "examples/color_scheme.rb", "examples/limit.rb", "examples/menus.rb", "examples/overwrite.rb", "examples/page_and_wrap.rb", "examples/password.rb", "examples/trapping_eof.rb", "examples/using_readline.rb", "lib/highline/color_scheme.rb", "lib/highline/compatibility.rb", "lib/highline/import.rb", "lib/highline/menu.rb", "lib/highline/question.rb", "lib/highline/system_extensions.rb", "lib/highline.rb", "test/tc_color_scheme.rb", "test/tc_highline.rb", "test/tc_import.rb", "test/tc_menu.rb", "test/ts_all.rb", "Rakefile", "setup.rb", "README", "INSTALL", "TODO", "CHANGELOG", "LICENSE"]
  s.homepage = %q{http://highline.rubyforge.org}
  s.rdoc_options = ["--title", "HighLine Documentation", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{highline}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{HighLine is a high-level command-line IO library.}
  s.test_files = ["test/ts_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
