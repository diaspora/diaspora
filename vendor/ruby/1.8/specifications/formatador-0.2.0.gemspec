# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{formatador}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["geemus (Wesley Beary)"]
  s.date = %q{2011-07-14}
  s.description = %q{STDOUT text formatting}
  s.email = %q{geemus@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["Gemfile", "README.rdoc", "Rakefile", "formatador.gemspec", "lib/formatador.rb", "lib/formatador/progressbar.rb", "lib/formatador/table.rb", "tests/basic_tests.rb", "tests/table_tests.rb", "tests/tests_helper.rb"]
  s.homepage = %q{http://github.com/geemus/NAME}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{formatador}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby STDOUT text formatting}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<shindo>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<shindo>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<shindo>, [">= 0"])
  end
end
