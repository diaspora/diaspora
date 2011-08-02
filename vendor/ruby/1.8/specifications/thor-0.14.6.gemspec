# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thor}
  s.version = "0.14.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yehuda Katz", "Jos\303\251 Valim"]
  s.date = %q{2010-11-20}
  s.description = %q{A scripting framework that replaces rake, sake and rubigen}
  s.email = ["ruby-thor@googlegroups.com"]
  s.executables = ["rake2thor", "thor"]
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "LICENSE", "README.md", "Thorfile"]
  s.files = ["bin/rake2thor", "bin/thor", "lib/thor.rb", "lib/thor/actions.rb", "lib/thor/actions/create_file.rb", "lib/thor/actions/create_link.rb", "lib/thor/actions/directory.rb", "lib/thor/actions/empty_directory.rb", "lib/thor/actions/file_manipulation.rb", "lib/thor/actions/inject_into_file.rb", "lib/thor/base.rb", "lib/thor/core_ext/file_binary_read.rb", "lib/thor/core_ext/hash_with_indifferent_access.rb", "lib/thor/core_ext/ordered_hash.rb", "lib/thor/error.rb", "lib/thor/group.rb", "lib/thor/invocation.rb", "lib/thor/parser.rb", "lib/thor/parser/argument.rb", "lib/thor/parser/arguments.rb", "lib/thor/parser/option.rb", "lib/thor/parser/options.rb", "lib/thor/rake_compat.rb", "lib/thor/runner.rb", "lib/thor/shell.rb", "lib/thor/shell/basic.rb", "lib/thor/shell/color.rb", "lib/thor/shell/html.rb", "lib/thor/task.rb", "lib/thor/util.rb", "lib/thor/version.rb", "spec/actions/create_file_spec.rb", "spec/actions/directory_spec.rb", "spec/actions/empty_directory_spec.rb", "spec/actions/file_manipulation_spec.rb", "spec/actions/inject_into_file_spec.rb", "spec/actions_spec.rb", "spec/base_spec.rb", "spec/core_ext/hash_with_indifferent_access_spec.rb", "spec/core_ext/ordered_hash_spec.rb", "spec/fixtures/application.rb", "spec/fixtures/bundle/execute.rb", "spec/fixtures/bundle/main.thor", "spec/fixtures/doc/%file_name%.rb.tt", "spec/fixtures/doc/README", "spec/fixtures/doc/block_helper.rb", "spec/fixtures/doc/components/.empty_directory", "spec/fixtures/doc/config.rb", "spec/fixtures/group.thor", "spec/fixtures/invoke.thor", "spec/fixtures/path with spaces", "spec/fixtures/script.thor", "spec/fixtures/task.thor", "spec/group_spec.rb", "spec/invocation_spec.rb", "spec/parser/argument_spec.rb", "spec/parser/arguments_spec.rb", "spec/parser/option_spec.rb", "spec/parser/options_spec.rb", "spec/rake_compat_spec.rb", "spec/register_spec.rb", "spec/runner_spec.rb", "spec/shell/basic_spec.rb", "spec/shell/color_spec.rb", "spec/shell/html_spec.rb", "spec/shell_spec.rb", "spec/spec_helper.rb", "spec/task_spec.rb", "spec/thor_spec.rb", "spec/util_spec.rb", "CHANGELOG.rdoc", "LICENSE", "README.md", "Thorfile"]
  s.homepage = %q{http://github.com/wycats/thor}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A scripting framework that replaces rake, sake and rubigen}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_development_dependency(%q<rdoc>, ["~> 2.5"])
      s.add_development_dependency(%q<rake>, [">= 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.1"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.3"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_dependency(%q<rdoc>, ["~> 2.5"])
      s.add_dependency(%q<rake>, [">= 0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.1"])
      s.add_dependency(%q<simplecov>, ["~> 0.3"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3"])
    s.add_dependency(%q<rdoc>, ["~> 2.5"])
    s.add_dependency(%q<rake>, [">= 0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.1"])
    s.add_dependency(%q<simplecov>, ["~> 0.3"])
  end
end
