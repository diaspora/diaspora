# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-openid}
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joshua Peek"]
  s.date = %q{2011-02-25}
  s.description = %q{    Provides a more HTTPish API around the ruby-openid library
}
  s.email = %q{josh@joshpeek.com}
  s.files = ["lib/rack/openid.rb", "lib/rack/openid/simple_auth.rb", "LICENSE", "README.rdoc"]
  s.homepage = %q{http://github.com/josh/rack-openid}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Provides a more HTTPish API around the ruby-openid library}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.1.0"])
      s.add_runtime_dependency(%q<ruby-openid>, [">= 2.1.8"])
    else
      s.add_dependency(%q<rack>, [">= 1.1.0"])
      s.add_dependency(%q<ruby-openid>, [">= 2.1.8"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.1.0"])
    s.add_dependency(%q<ruby-openid>, [">= 2.1.8"])
  end
end
