# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hashie}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2010-08-31}
  s.description = %q{Hashie is a small collection of tools that make hashes more powerful. Currently includes Mash (Mocking Hash) and Dash (Discrete Hash).}
  s.email = %q{michael@intridea.com}
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = [".document", ".gitignore", "Gemfile", "Gemfile.lock", "LICENSE", "README.rdoc", "Rakefile", "VERSION", "hashie.gemspec", "lib/hashie.rb", "lib/hashie/clash.rb", "lib/hashie/dash.rb", "lib/hashie/hash.rb", "lib/hashie/hash_extensions.rb", "lib/hashie/mash.rb", "lib/hashie/trash.rb", "spec/hashie/clash_spec.rb", "spec/hashie/dash_spec.rb", "spec/hashie/hash_spec.rb", "spec/hashie/mash_spec.rb", "spec/hashie/trash_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/intridea/hashie}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Your friendly neighborhood hash toolkit.}
  s.test_files = ["spec/hashie/clash_spec.rb", "spec/hashie/dash_spec.rb", "spec/hashie/hash_spec.rb", "spec/hashie/mash_spec.rb", "spec/hashie/trash_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
