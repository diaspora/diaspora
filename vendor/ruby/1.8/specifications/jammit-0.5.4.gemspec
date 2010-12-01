# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jammit}
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Ashkenas"]
  s.date = %q{2010-11-08}
  s.default_executable = %q{jammit}
  s.description = %q{    Jammit is an industrial strength asset packaging library for Rails,
    providing both the CSS and JavaScript concatenation and compression that
    you'd expect, as well as YUI Compressor and Closure Compiler compatibility,
    ahead-of-time gzipping, built-in JavaScript template support, and optional
    Data-URI / MHTML image embedding.
}
  s.email = %q{jeremy@documentcloud.org}
  s.executables = ["jammit"]
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/jammit/command_line.rb", "lib/jammit/compressor.rb", "lib/jammit/controller.rb", "lib/jammit/dependencies.rb", "lib/jammit/helper.rb", "lib/jammit/jst.js", "lib/jammit/packager.rb", "lib/jammit/railtie.rb", "lib/jammit/routes.rb", "lib/jammit.rb", "bin/jammit", "rails/routes.rb", "jammit.gemspec", "LICENSE", "README"]
  s.homepage = %q{http://documentcloud.github.com/jammit/}
  s.rdoc_options = ["--title", "Jammit", "--exclude", "test", "--main", "README", "--all"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jammit}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Industrial Strength Asset Packaging for Rails}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<yui-compressor>, [">= 0.9.1"])
      s.add_runtime_dependency(%q<closure-compiler>, [">= 0.1.0"])
    else
      s.add_dependency(%q<yui-compressor>, [">= 0.9.1"])
      s.add_dependency(%q<closure-compiler>, [">= 0.1.0"])
    end
  else
    s.add_dependency(%q<yui-compressor>, [">= 0.9.1"])
    s.add_dependency(%q<closure-compiler>, [">= 0.1.0"])
  end
end
