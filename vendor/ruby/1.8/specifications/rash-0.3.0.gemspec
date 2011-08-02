# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rash}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["tcocca"]
  s.date = %q{2010-08-31}
  s.description = %q{simple extension to Hashie::Mash for rubyified keys, all keys are converted to underscore to eliminate horrible camelCasing}
  s.email = %q{tom.cocca@gmail.com}
  s.files = [".document", ".gitignore", ".rspec", "Gemfile", "LICENSE", "README.rdoc", "Rakefile", "lib/hashie/rash.rb", "lib/rash.rb", "lib/rash/version.rb", "rash.gemspec", "spec/rash_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/tcocca/rash}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{simple extension to Hashie::Mash for rubyified keys}
  s.test_files = ["spec/rash_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hashie>, ["~> 1.0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5.0"])
    else
      s.add_dependency(%q<hashie>, ["~> 1.0.0"])
      s.add_dependency(%q<rspec>, ["~> 2.5.0"])
    end
  else
    s.add_dependency(%q<hashie>, ["~> 1.0.0"])
    s.add_dependency(%q<rspec>, ["~> 2.5.0"])
  end
end
