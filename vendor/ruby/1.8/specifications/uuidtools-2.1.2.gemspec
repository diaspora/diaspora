# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{uuidtools}
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bob Aman"]
  s.date = %q{2011-02-02}
  s.description = %q{A simple universally unique ID generation library.
}
  s.email = %q{bob@sporkmonger.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/compat/securerandom.rb", "lib/uuidtools/version.rb", "lib/uuidtools.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/uuidtools/mac_address_spec.rb", "spec/uuidtools/utility_spec.rb", "spec/uuidtools/uuid_creation_spec.rb", "spec/uuidtools/uuid_parsing_spec.rb", "tasks/benchmark.rake", "tasks/clobber.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/metrics.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/spec.rake", "website/index.html", "CHANGELOG", "LICENSE", "Rakefile", "README"]
  s.homepage = %q{http://uuidtools.rubyforge.org/}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{uuidtools}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{UUID generator}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0.8.3"])
      s.add_development_dependency(%q<rspec>, [">= 1.1.11"])
      s.add_development_dependency(%q<launchy>, [">= 0.3.2"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.3"])
      s.add_dependency(%q<rspec>, [">= 1.1.11"])
      s.add_dependency(%q<launchy>, [">= 0.3.2"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.3"])
    s.add_dependency(%q<rspec>, [">= 1.1.11"])
    s.add_dependency(%q<launchy>, [">= 0.3.2"])
  end
end
