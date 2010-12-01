# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activeresource}
  s.version = "3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.date = %q{2010-10-14}
  s.description = %q{REST on Rails. Wrap your RESTful web app with Ruby classes and work with them like Active Record models.}
  s.email = %q{david@loudthinking.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["CHANGELOG", "README.rdoc", "examples/simple.rb", "lib/active_resource/base.rb", "lib/active_resource/connection.rb", "lib/active_resource/custom_methods.rb", "lib/active_resource/exceptions.rb", "lib/active_resource/formats/json_format.rb", "lib/active_resource/formats/xml_format.rb", "lib/active_resource/formats.rb", "lib/active_resource/http_mock.rb", "lib/active_resource/log_subscriber.rb", "lib/active_resource/observing.rb", "lib/active_resource/railtie.rb", "lib/active_resource/schema.rb", "lib/active_resource/validations.rb", "lib/active_resource/version.rb", "lib/active_resource.rb"]
  s.homepage = %q{http://www.rubyonrails.org}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{activeresource}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{REST modeling framework (part of Rails).}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["= 3.0.1"])
      s.add_runtime_dependency(%q<activemodel>, ["= 3.0.1"])
    else
      s.add_dependency(%q<activesupport>, ["= 3.0.1"])
      s.add_dependency(%q<activemodel>, ["= 3.0.1"])
    end
  else
    s.add_dependency(%q<activesupport>, ["= 3.0.1"])
    s.add_dependency(%q<activemodel>, ["= 3.0.1"])
  end
end
