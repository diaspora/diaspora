# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{typhoeus}
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Dix", "David Balatero"]
  s.date = %q{2011-02-24}
  s.description = %q{Like a modern code version of the mythical beast with 100 serpent heads, Typhoeus runs HTTP requests in parallel while cleanly encapsulating handling logic.}
  s.email = %q{dbalatero@gmail.com}
  s.extensions = ["ext/typhoeus/extconf.rb"]
  s.extra_rdoc_files = ["LICENSE", "README.textile"]
  s.files = ["CHANGELOG.markdown", "Gemfile", "Gemfile.lock", "LICENSE", "README.textile", "Rakefile", "VERSION", "benchmarks/profile.rb", "benchmarks/vs_nethttp.rb", "examples/file.rb", "examples/times.rb", "examples/twitter.rb", "ext/typhoeus/.gitignore", "ext/typhoeus/extconf.rb", "ext/typhoeus/native.c", "ext/typhoeus/native.h", "ext/typhoeus/typhoeus_easy.c", "ext/typhoeus/typhoeus_easy.h", "ext/typhoeus/typhoeus_form.c", "ext/typhoeus/typhoeus_form.h", "ext/typhoeus/typhoeus_multi.c", "ext/typhoeus/typhoeus_multi.h", "lib/typhoeus.rb", "lib/typhoeus/.gitignore", "lib/typhoeus/easy.rb", "lib/typhoeus/filter.rb", "lib/typhoeus/form.rb", "lib/typhoeus/hydra.rb", "lib/typhoeus/hydra/callbacks.rb", "lib/typhoeus/hydra/connect_options.rb", "lib/typhoeus/hydra/stubbing.rb", "lib/typhoeus/hydra_mock.rb", "lib/typhoeus/multi.rb", "lib/typhoeus/normalized_header_hash.rb", "lib/typhoeus/remote.rb", "lib/typhoeus/remote_method.rb", "lib/typhoeus/remote_proxy_object.rb", "lib/typhoeus/request.rb", "lib/typhoeus/response.rb", "lib/typhoeus/service.rb", "lib/typhoeus/utils.rb", "profilers/valgrind.rb", "spec/fixtures/placeholder.gif", "spec/fixtures/placeholder.txt", "spec/fixtures/placeholder.ukn", "spec/fixtures/result_set.xml", "spec/servers/app.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/typhoeus/easy_spec.rb", "spec/typhoeus/filter_spec.rb", "spec/typhoeus/form_spec.rb", "spec/typhoeus/hydra_mock_spec.rb", "spec/typhoeus/hydra_spec.rb", "spec/typhoeus/multi_spec.rb", "spec/typhoeus/normalized_header_hash_spec.rb", "spec/typhoeus/remote_method_spec.rb", "spec/typhoeus/remote_proxy_object_spec.rb", "spec/typhoeus/remote_spec.rb", "spec/typhoeus/request_spec.rb", "spec/typhoeus/response_spec.rb", "spec/typhoeus/utils_spec.rb", "typhoeus.gemspec"]
  s.homepage = %q{http://github.com/dbalatero/typhoeus}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A library for interacting with web services (and building SOAs) at blinding speed.}
  s.test_files = ["examples/file.rb", "examples/times.rb", "examples/twitter.rb", "spec/servers/app.rb", "spec/spec_helper.rb", "spec/typhoeus/easy_spec.rb", "spec/typhoeus/filter_spec.rb", "spec/typhoeus/form_spec.rb", "spec/typhoeus/hydra_mock_spec.rb", "spec/typhoeus/hydra_spec.rb", "spec/typhoeus/multi_spec.rb", "spec/typhoeus/normalized_header_hash_spec.rb", "spec/typhoeus/remote_method_spec.rb", "spec/typhoeus/remote_proxy_object_spec.rb", "spec/typhoeus/remote_spec.rb", "spec/typhoeus/request_spec.rb", "spec/typhoeus/response_spec.rb", "spec/typhoeus/utils_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<diff-lcs>, [">= 0"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<mime-types>, [">= 0"])
      s.add_dependency(%q<mime-types>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<diff-lcs>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 0"])
    s.add_dependency(%q<mime-types>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<diff-lcs>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
  end
end
