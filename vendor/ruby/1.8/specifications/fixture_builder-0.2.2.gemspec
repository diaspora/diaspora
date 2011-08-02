# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fixture_builder}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Dy", "David Stevenson"]
  s.date = %q{2011-04-29}
  s.description = %q{FixtureBuilder allows testers to use their existing factories, like FactoryGirl, to generate high performance fixtures that can be shared across all your tests}
  s.email = %q{stellar256@hotmail.com}
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["MIT-LICENSE", "README.markdown", "Rakefile", "VERSION", "fixture_builder.gemspec", "lib/fixture_builder.rb", "lib/tasks/fixture_builder.rake", "test/fixture_builder_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/rdy/fixture_builder}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{fixture_builder}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Build YAML fixtures using object factories}
  s.test_files = ["test/fixture_builder_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end
