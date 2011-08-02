# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{multi_json}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh", "Josh Kalderimis", "Erik Michaels-Ober"]
  s.date = %q{2011-05-23}
  s.description = %q{A gem to provide swappable JSON backends utilizing Yajl::Ruby, the JSON gem, JSON pure, or a vendored version of okjson.}
  s.email = ["michael@intridea.com", "josh.kalderimis@gmail.com", "sferik@gmail.com"]
  s.extra_rdoc_files = ["LICENSE.md", "README.md"]
  s.files = [".document", ".gemtest", ".gitignore", ".rspec", ".travis.yml", "Gemfile", "LICENSE.md", "README.md", "Rakefile", "lib/multi_json.rb", "lib/multi_json/engines/json_gem.rb", "lib/multi_json/engines/json_pure.rb", "lib/multi_json/engines/ok_json.rb", "lib/multi_json/engines/yajl.rb", "lib/multi_json/vendor/ok_json.rb", "lib/multi_json/version.rb", "multi_json.gemspec", "spec/helper.rb", "spec/multi_json_spec.rb"]
  s.homepage = %q{http://github.com/intridea/multi_json}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A gem to provide swappable JSON backends.}
  s.test_files = ["spec/helper.rb", "spec/multi_json_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rdoc>, ["= 3.5.1"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
    else
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rdoc>, ["= 3.5.1"])
      s.add_dependency(%q<rspec>, ["~> 2.6"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rdoc>, ["= 3.5.1"])
    s.add_dependency(%q<rspec>, ["~> 2.6"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
  end
end
