# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{polyglot}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Clifford Heath"]
  s.date = %q{2010-03-28}
  s.description = %q{Allows custom language loaders for specified file extensions to be hooked into require}
  s.email = %q{cjheath@rubyforge.org}
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/polyglot.rb", "lib/polyglot/version.rb", "test/test_helper.rb", "test/test_polyglot.rb"]
  s.homepage = %q{http://polyglot.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{polyglot}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Allows custom language loaders for specified file extensions to be hooked into require}
  s.test_files = ["test/test_helper.rb", "test/test_polyglot.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
