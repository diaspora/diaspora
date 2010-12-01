# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{configuration}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ara T. Howard"]
  s.date = %q{2010-11-18}
  s.email = %q{ara.t.howard@gmail.com}
  s.files = ["config/a.rb", "config/b.rb", "config/c.rb", "config/d.rb", "config/e.rb", "configuration.gemspec", "lib/configuration.rb", "LICENSE", "Rakefile", "README", "README.erb", "samples/a.rb", "samples/b.rb", "samples/c.rb", "samples/d.rb", "samples/e.rb"]
  s.homepage = %q{http://github.com/ahoward/configuration/tree/master}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{codeforpeople}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{configuration}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
