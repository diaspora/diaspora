# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{systemu}
  s.version = "1.2.0"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Ara T. Howard"]
  s.autorequire = %q{systemu}
  s.cert_chain = nil
  s.date = %q{2007-12-06}
  s.email = %q{ara.t.howard@noaa.gov}
  s.files = ["a.rb", "gemspec.rb", "gen_readme.rb", "install.rb", "lib", "lib/systemu.rb", "README", "README.tmpl", "samples", "samples/a.rb", "samples/b.rb", "samples/c.rb", "samples/d.rb", "samples/e.rb", "samples/f.rb"]
  s.homepage = %q{http://codeforpeople.com/lib/ruby/systemu/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{systemu}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
