# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{closure-compiler}
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Ashkenas", "Jordan Brough"]
  s.date = %q{2010-09-28}
  s.description = %q{    A Ruby Wrapper for the Google Closure Compiler.
}
  s.email = %q{jeremy@documentcloud.org}
  s.files = ["lib/closure/compiler.rb", "lib/closure/popen.rb", "lib/closure-compiler.rb", "vendor/closure-compiler-20100917.jar", "closure-compiler.gemspec", "README.textile", "LICENSE", "COPYING"]
  s.homepage = %q{http://github.com/documentcloud/closure-compiler/}
  s.rdoc_options = ["--title", "Ruby Closure Compiler", "--exclude", "test", "--all"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{closure-compiler}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby Wrapper for the Google Closure Compiler}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
