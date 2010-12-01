# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{xml-simple}
  s.version = "1.0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Maik Schmidt"]
  s.date = %q{2009-02-27}
  s.email = %q{contact@maik-schmidt.de}
  s.files = ["lib/xmlsimple.rb"]
  s.homepage = %q{http://xml-simple.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{xml-simple}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A simple API for XML processing.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
