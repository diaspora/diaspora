# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{launchy}
  s.version = "0.3.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Hinegardner"]
  s.date = %q{2010-07-19}
  s.default_executable = %q{launchy}
  s.description = %q{Launchy is helper class for launching cross-platform applications in a
fire and forget manner.

There are application concepts (browser, email client, etc) that are
common across all platforms, and they may be launched differently on
each platform.  Launchy is here to make a common approach to launching
external application from within ruby programs.}
  s.email = %q{jeremy@copiousfreetime.org}
  s.executables = ["launchy"]
  s.extra_rdoc_files = ["README", "HISTORY", "LICENSE", "lib/launchy/application.rb", "lib/launchy/browser.rb", "lib/launchy/command_line.rb", "lib/launchy/paths.rb", "lib/launchy/version.rb", "lib/launchy.rb"]
  s.files = ["bin/launchy", "lib/launchy/application.rb", "lib/launchy/browser.rb", "lib/launchy/command_line.rb", "lib/launchy/paths.rb", "lib/launchy/version.rb", "lib/launchy.rb", "spec/application_spec.rb", "spec/browser_spec.rb", "spec/launchy_spec.rb", "spec/paths_spec.rb", "spec/spec_helper.rb", "spec/version_spec.rb", "spec/tattle-host-os.yml", "README", "HISTORY", "LICENSE", "tasks/announce.rake", "tasks/distribution.rake", "tasks/documentation.rake", "tasks/rspec.rake", "tasks/rubyforge.rake", "tasks/config.rb", "tasks/utils.rb", "Rakefile", "gemspec.rb"]
  s.homepage = %q{http://copiousfreetime.rubyforge.org/launchy/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{copiousfreetime}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Launchy is helper class for launching cross-platform applications in a fire and forget manner}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.1"])
      s.add_runtime_dependency(%q<configuration>, [">= 0.0.5"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.1"])
      s.add_dependency(%q<configuration>, [">= 0.0.5"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.1"])
    s.add_dependency(%q<configuration>, [">= 0.0.5"])
  end
end
