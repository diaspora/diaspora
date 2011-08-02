# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fuubar}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nicholas Evans", "Jeff Kreeftmeijer"]
  s.date = %q{2011-05-22}
  s.description = %q{the instafailing RSpec progress bar formatter}
  s.email = ["jeff@kreeftmeijer.nl"]
  s.files = [".gitignore", ".rspec", "Gemfile", "LICENSE", "README.textile", "Rakefile", "fuubar.gemspec", "lib/fuubar.rb", "spec/fuubar_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{https://github.com/jeffkreeftmeijer/fuubar}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{fuubar}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{the instafailing RSpec progress bar formatter}
  s.test_files = ["spec/fuubar_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, ["~> 2.0"])
      s.add_runtime_dependency(%q<ruby-progressbar>, ["~> 0.0.10"])
      s.add_runtime_dependency(%q<rspec-instafail>, ["~> 0.1.4"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<ruby-progressbar>, ["~> 0.0.10"])
      s.add_dependency(%q<rspec-instafail>, ["~> 0.1.4"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<ruby-progressbar>, ["~> 0.0.10"])
    s.add_dependency(%q<rspec-instafail>, ["~> 0.1.4"])
  end
end
