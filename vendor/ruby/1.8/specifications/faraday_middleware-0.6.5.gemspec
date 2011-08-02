# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{faraday_middleware}
  s.version = "0.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Erik Michaels-Ober", "Wynn Netherland"]
  s.date = %q{2011-06-22}
  s.description = %q{Various middleware for Faraday}
  s.email = ["sferik@gmail.com", "wynn.netherland@gmail.com"]
  s.files = [".gemtest", ".gitignore", ".rspec", ".travis.yml", "CHANGELOG.md", "Gemfile", "LICENSE.md", "README.md", "Rakefile", "faraday_middleware.gemspec", "lib/faraday/request/oauth.rb", "lib/faraday/request/oauth2.rb", "lib/faraday/response/mashify.rb", "lib/faraday/response/parse_json.rb", "lib/faraday/response/parse_marshal.rb", "lib/faraday/response/parse_xml.rb", "lib/faraday/response/parse_yaml.rb", "lib/faraday/response/rashify.rb", "lib/faraday_middleware.rb", "lib/faraday_middleware/version.rb", "spec/helper.rb", "spec/mashify_spec.rb", "spec/oauth2_spec.rb", "spec/oauth_spec.rb", "spec/parse_json_spec.rb", "spec/parse_marshal_spec.rb", "spec/parse_xml_spec.rb", "spec/parse_yaml_spec.rb", "spec/rashify_spec.rb"]
  s.homepage = %q{https://github.com/pengwynn/faraday_middleware}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Various middleware for Faraday}
  s.test_files = ["spec/helper.rb", "spec/mashify_spec.rb", "spec/oauth2_spec.rb", "spec/oauth_spec.rb", "spec/parse_json_spec.rb", "spec/parse_marshal_spec.rb", "spec/parse_xml_spec.rb", "spec/parse_yaml_spec.rb", "spec/rashify_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.6.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_development_dependency(%q<rash>, ["~> 0.3"])
      s.add_development_dependency(%q<json_pure>, ["~> 1.5"])
      s.add_development_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_development_dependency(%q<multi_xml>, ["~> 0.2"])
      s.add_development_dependency(%q<oauth2>, ["~> 0.2"])
      s.add_development_dependency(%q<simple_oauth>, ["~> 0.1"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.6.0"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rspec>, ["~> 2.6"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_dependency(%q<rash>, ["~> 0.3"])
      s.add_dependency(%q<json_pure>, ["~> 1.5"])
      s.add_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_dependency(%q<multi_xml>, ["~> 0.2"])
      s.add_dependency(%q<oauth2>, ["~> 0.2"])
      s.add_dependency(%q<simple_oauth>, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.6.0"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rspec>, ["~> 2.6"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
    s.add_dependency(%q<rash>, ["~> 0.3"])
    s.add_dependency(%q<json_pure>, ["~> 1.5"])
    s.add_dependency(%q<multi_json>, ["~> 1.0"])
    s.add_dependency(%q<multi_xml>, ["~> 0.2"])
    s.add_dependency(%q<oauth2>, ["~> 0.2"])
    s.add_dependency(%q<simple_oauth>, ["~> 0.1"])
  end
end
