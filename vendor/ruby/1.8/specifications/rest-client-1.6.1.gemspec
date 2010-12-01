# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rest-client}
  s.version = "1.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Wiggins", "Julien Kirch"]
  s.date = %q{2010-07-24}
  s.default_executable = %q{restclient}
  s.description = %q{A simple Simple HTTP and REST client for Ruby, inspired by the Sinatra microframework style of specifying actions: get, put, post, delete.}
  s.email = %q{rest.client@librelist.com}
  s.executables = ["restclient"]
  s.extra_rdoc_files = ["README.rdoc", "history.md"]
  s.files = ["README.rdoc", "Rakefile", "VERSION", "bin/restclient", "lib/rest_client.rb", "lib/rest-client.rb", "lib/restclient.rb", "lib/restclient/exceptions.rb", "lib/restclient/abstract_response.rb", "lib/restclient/net_http_ext.rb", "lib/restclient/payload.rb", "lib/restclient/raw_response.rb", "lib/restclient/request.rb", "lib/restclient/resource.rb", "lib/restclient/response.rb", "spec/base.rb", "spec/exceptions_spec.rb", "spec/integration_spec.rb", "spec/master_shake.jpg", "spec/abstract_response_spec.rb", "spec/payload_spec.rb", "spec/raw_response_spec.rb", "spec/request_spec.rb", "spec/request2_spec.rb", "spec/resource_spec.rb", "spec/response_spec.rb", "spec/restclient_spec.rb", "spec/integration/certs/equifax.crt", "spec/integration/certs/verisign.crt", "spec/integration/request_spec.rb", "history.md"]
  s.homepage = %q{http://github.com/archiloque/rest-client}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rest-client}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simple REST client for Ruby, inspired by microframework syntax for specifying actions.}
  s.test_files = ["spec/base.rb", "spec/exceptions_spec.rb", "spec/integration_spec.rb", "spec/abstract_response_spec.rb", "spec/payload_spec.rb", "spec/raw_response_spec.rb", "spec/request_spec.rb", "spec/request2_spec.rb", "spec/resource_spec.rb", "spec/response_spec.rb", "spec/restclient_spec.rb", "spec/integration/request_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
    else
      s.add_dependency(%q<mime-types>, [">= 1.16"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 1.16"])
  end
end
