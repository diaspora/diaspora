# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{redis-namespace}
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Wanstrath"]
  s.date = %q{2010-07-24}
  s.description = %q{Adds a Redis::Namespace class which can be used to namespace calls
to Redis. This is useful when using a single instance of Redis with
multiple, different applications.
}
  s.email = %q{chris@ozmm.org}
  s.files = ["README.md", "Rakefile", "LICENSE", "lib/redis/namespace.rb", "lib/redis-namespace.rb", "spec/redis_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/defunkt/redis-namespace}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Namespaces Redis commands.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>, ["< 3.0.0"])
    else
      s.add_dependency(%q<redis>, ["< 3.0.0"])
    end
  else
    s.add_dependency(%q<redis>, ["< 3.0.0"])
  end
end
