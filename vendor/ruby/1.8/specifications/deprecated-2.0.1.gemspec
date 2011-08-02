# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{deprecated}
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Erik Hollensbe"]
  s.date = %q{2008-07-26}
  s.email = %q{erik@hollensbe.org}
  s.files = ["lib/deprecated.rb", "test/deprecated.rb"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{deprecated}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{An easy way to handle deprecating and conditionally running deprecated code}
  s.test_files = ["test/deprecated.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
