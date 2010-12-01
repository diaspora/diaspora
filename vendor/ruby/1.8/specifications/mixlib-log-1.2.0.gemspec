# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mixlib-log}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Opscode, Inc."]
  s.date = %q{2010-10-19}
  s.email = %q{info@opscode.com}
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = [".gitignore", "LICENSE", "NOTICE", "README.rdoc", "Rakefile", "VERSION.yml", "features/log.feature", "features/steps/log.rb", "features/support/env.rb", "features/support/logit.rb", "lib/mixlib/log.rb", "lib/mixlib/log/formatter.rb", "spec/mixlib/log/formatter_spec.rb", "spec/mixlib/log_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = %q{http://www.opscode.com}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A gem that provides a simple mixin for log functionality}
  s.test_files = ["spec/mixlib/log/formatter_spec.rb", "spec/mixlib/log_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
