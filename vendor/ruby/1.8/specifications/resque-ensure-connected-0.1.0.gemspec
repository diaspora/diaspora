# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{resque-ensure-connected}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Sonnek"]
  s.date = %q{2010-12-06}
  s.description = %q{ensure active record connections are valid before performing work}
  s.email = %q{ryan@codecrate.com}
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc"]
  s.files = [".document", "Gemfile", "Gemfile.lock", "LICENSE.txt", "README.rdoc", "Rakefile", "VERSION", "lib/resque-ensure-connected.rb", "resque-ensure-connected.gemspec", "test/helper.rb", "test/test_resque-ensure-connected.rb"]
  s.homepage = %q{http://github.com/wireframe/resque-ensure-connected}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{ensure active record connections are valid before performing work}
  s.test_files = ["test/helper.rb", "test/test_resque-ensure-connected.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<resque>, ["~> 1.10.0"])
      s.add_runtime_dependency(%q<activerecord>, [">= 2.3.5"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<resque_unit>, [">= 0"])
    else
      s.add_dependency(%q<resque>, ["~> 1.10.0"])
      s.add_dependency(%q<activerecord>, [">= 2.3.5"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<resque_unit>, [">= 0"])
    end
  else
    s.add_dependency(%q<resque>, ["~> 1.10.0"])
    s.add_dependency(%q<activerecord>, [">= 2.3.5"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<resque_unit>, [">= 0"])
  end
end
