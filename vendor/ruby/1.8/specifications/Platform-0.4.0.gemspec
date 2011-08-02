# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{Platform}
  s.version = "0.4.0"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Mower"]
  s.autorequire = %q{platform}
  s.cert_chain = nil
  s.date = %q{2005-12-02}
  s.email = %q{self@mattmower.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/platform.rb", "README"]
  s.homepage = %q{http://rubyforge.org/projects/platform/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Hopefully robust platform sensing}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
