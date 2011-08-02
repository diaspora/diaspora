# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mixlib-config}
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Opscode, Inc."]
  s.date = %q{2010-06-20}
  s.email = %q{info@opscode.com}
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = [".gitignore", "LICENSE", "NOTICE", "README.rdoc", "Rakefile", "VERSION.yml", "features/mixlib_config.feature", "features/step_definitions/mixlib_config_steps.rb", "features/steps/config_steps.rb", "features/support/bobo.config", "features/support/config_it.rb", "features/support/env.rb", "lib/mixlib/config.rb", "spec/mixlib/config_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = %q{http://www.opscode.com}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A class based config mixin, similar to the one found in Chef.}
  s.test_files = ["spec/mixlib/config_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
