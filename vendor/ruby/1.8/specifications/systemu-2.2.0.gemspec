# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{systemu}
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ara T. Howard"]
  s.date = %q{2011-04-12}
  s.description = %q{description: systemu kicks the ass}
  s.email = %q{ara.t.howard@gmail.com}
  s.files = ["lib/systemu.rb", "LICENSE", "Rakefile", "README", "README.erb", "samples/a.rb", "samples/b.rb", "samples/c.rb", "samples/d.rb", "samples/e.rb", "samples/f.rb", "systemu.gemspec"]
  s.homepage = %q{http://github.com/ahoward/systemu}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{codeforpeople}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{systemu}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
