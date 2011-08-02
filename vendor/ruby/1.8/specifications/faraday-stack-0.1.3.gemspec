# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{faraday-stack}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mislav Marohni\304\207"]
  s.date = %q{2011-07-08}
  s.email = %q{mislav.marohnic@gmail.com}
  s.files = ["lib/faraday-stack.rb", "lib/faraday_stack/addressable_patch.rb", "lib/faraday_stack/caching.rb", "lib/faraday_stack/follow_redirects.rb", "lib/faraday_stack/instrumentation.rb", "lib/faraday_stack/rack_compatible.rb", "lib/faraday_stack/response_html.rb", "lib/faraday_stack/response_json.rb", "lib/faraday_stack/response_middleware.rb", "lib/faraday_stack/response_xml.rb", "lib/faraday_stack.rb", "test/caching_test.rb", "test/factory_test.rb", "test/follow_redirects_test.rb", "test/response_middleware_test.rb", "test/test_helper.rb", "README.md"]
  s.homepage = %q{https://github.com/mislav/faraday-stack}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Great Faraday stack for consuming all kinds of APIs}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.6"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.6"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.6"])
  end
end
