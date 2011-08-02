# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{excon}
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["geemus (Wesley Beary)"]
  s.date = %q{2010-10-11}
  s.description = %q{EXtended http(s) CONnections}
  s.email = %q{geemus@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["Gemfile", "README.rdoc", "Rakefile", "benchmarks/excon_vs.rb", "benchmarks/headers_split_vs_match.rb", "benchmarks/strip_newline.rb", "excon.gemspec", "lib/excon.rb", "lib/excon/connection.rb", "lib/excon/errors.rb", "lib/excon/response.rb", "tests/config.ru", "tests/test_helper.rb", "tests/threaded_tests.rb"]
  s.homepage = %q{http://github.com/geemus/NAME}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{excon}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{speed, persistence, http(s)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
