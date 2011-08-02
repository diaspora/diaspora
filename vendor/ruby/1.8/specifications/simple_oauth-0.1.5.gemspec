# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{simple_oauth}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve Richert", "Erik Michaels-Ober"]
  s.date = %q{2011-05-06}
  s.description = %q{Simply builds and verifies OAuth headers}
  s.email = ["steve.richert@gmail.com", "sferik@gmail.com"]
  s.files = [".gemtest", ".gitignore", ".travis.yml", ".yardopts", "Gemfile", "LICENSE.md", "README.md", "Rakefile", "init.rb", "lib/simple_oauth.rb", "lib/simple_oauth/core_ext/object.rb", "lib/simple_oauth/header.rb", "lib/simple_oauth/version.rb", "simple_oauth.gemspec", "test/helper.rb", "test/rsa_private_key", "test/simple_oauth_test.rb"]
  s.homepage = %q{http://github.com/laserlemon/simple_oauth}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simply builds and verifies OAuth headers}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9"])
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_development_dependency(%q<turn>, ["~> 0.8"])
      s.add_development_dependency(%q<yard>, ["~> 0.6"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<mocha>, ["~> 0.9"])
      s.add_dependency(%q<rake>, ["~> 0.8"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_dependency(%q<turn>, ["~> 0.8"])
      s.add_dependency(%q<yard>, ["~> 0.6"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<mocha>, ["~> 0.9"])
    s.add_dependency(%q<rake>, ["~> 0.8"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
    s.add_dependency(%q<turn>, ["~> 0.8"])
    s.add_dependency(%q<yard>, ["~> 0.6"])
  end
end
