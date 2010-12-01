# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pubsubhubbub}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ilya Grigorik"]
  s.date = %q{2010-05-01}
  s.description = %q{Asynchronous PubSubHubbub client for Ruby}
  s.email = %q{ilya@igvita.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "Rakefile", "VERSION", "lib/pubsubhubbub.rb", "lib/pubsubhubbub/client.rb", "test/test_client.rb"]
  s.homepage = %q{http://github.com/igrigorik/pubsubhubbub}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pubsubhubbub}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Asynchronous PubSubHubbub client for Ruby}
  s.test_files = ["test/test_client.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.9"])
      s.add_runtime_dependency(%q<em-http-request>, [">= 0.1.5"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0.12.9"])
      s.add_dependency(%q<em-http-request>, [">= 0.1.5"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0.12.9"])
    s.add_dependency(%q<em-http-request>, [">= 0.1.5"])
  end
end
