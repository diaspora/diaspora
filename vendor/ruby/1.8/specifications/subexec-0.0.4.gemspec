# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{subexec}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Kieltyka"]
  s.date = %q{2010-07-07}
  s.description = %q{Subexec spawns an external command with a timeout}
  s.email = ["peter@nulayer.com"]
  s.files = ["README.rdoc", "VERSION", "lib/subexec.rb"]
  s.homepage = %q{http://github.com/nulayer/subexec}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Subexec spawns an external command with a timeout}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
