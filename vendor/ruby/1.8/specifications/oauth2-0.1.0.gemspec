# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oauth2}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2010-10-13}
  s.description = %q{A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth gem.}
  s.email = %q{michael@intridea.com}
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = [".document", ".gitignore", ".rspec", "CHANGELOG.rdoc", "Gemfile", "Gemfile.lock", "LICENSE", "README.rdoc", "Rakefile", "lib/oauth2.rb", "lib/oauth2/access_token.rb", "lib/oauth2/client.rb", "lib/oauth2/response_object.rb", "lib/oauth2/strategy/base.rb", "lib/oauth2/strategy/web_server.rb", "lib/oauth2/version.rb", "oauth2.gemspec", "spec/oauth2/access_token_spec.rb", "spec/oauth2/client_spec.rb", "spec/oauth2/strategy/base_spec.rb", "spec/oauth2/strategy/web_server_spec.rb", "spec/spec_helper.rb", "specs.watchr"]
  s.homepage = %q{http://github.com/intridea/oauth2}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Ruby wrapper for the OAuth 2.0 protocol.}
  s.test_files = ["spec/oauth2/access_token_spec.rb", "spec/oauth2/client_spec.rb", "spec/oauth2/strategy/base_spec.rb", "spec/oauth2/strategy/web_server_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.5.0"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 0.0.4"])
      s.add_development_dependency(%q<json_pure>, ["~> 1.4.6"])
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
      s.add_development_dependency(%q<rcov>, ["~> 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.5.0"])
      s.add_dependency(%q<multi_json>, ["~> 0.0.4"])
      s.add_dependency(%q<json_pure>, ["~> 1.4.6"])
      s.add_dependency(%q<rake>, ["~> 0.8"])
      s.add_dependency(%q<rcov>, ["~> 0.9"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.5.0"])
    s.add_dependency(%q<multi_json>, ["~> 0.0.4"])
    s.add_dependency(%q<json_pure>, ["~> 1.4.6"])
    s.add_dependency(%q<rake>, ["~> 0.8"])
    s.add_dependency(%q<rcov>, ["~> 0.9"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
  end
end
