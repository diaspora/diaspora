# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{plucky}
  s.version = "0.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Nunemaker"]
  s.date = %q{2010-10-11}
  s.email = ["nunemaker@gmail.com"]
  s.files = ["lib/plucky/criteria_hash.rb", "lib/plucky/extensions/duplicable.rb", "lib/plucky/extensions/symbol.rb", "lib/plucky/extensions.rb", "lib/plucky/options_hash.rb", "lib/plucky/pagination/decorator.rb", "lib/plucky/pagination/paginator.rb", "lib/plucky/query.rb", "lib/plucky/version.rb", "lib/plucky.rb", "LICENSE", "README.rdoc"]
  s.homepage = %q{http://github.com/jnunemaker/plucky}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Thin layer over the ruby driver that allows you to quickly grab hold of your data (pluck it!).}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo>, ["~> 1.1"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11"])
      s.add_development_dependency(%q<jnunemaker-matchy>, ["~> 0.4.0"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9.8"])
      s.add_development_dependency(%q<log_buddy>, [">= 0"])
    else
      s.add_dependency(%q<mongo>, ["~> 1.1"])
      s.add_dependency(%q<shoulda>, ["~> 2.11"])
      s.add_dependency(%q<jnunemaker-matchy>, ["~> 0.4.0"])
      s.add_dependency(%q<mocha>, ["~> 0.9.8"])
      s.add_dependency(%q<log_buddy>, [">= 0"])
    end
  else
    s.add_dependency(%q<mongo>, ["~> 1.1"])
    s.add_dependency(%q<shoulda>, ["~> 2.11"])
    s.add_dependency(%q<jnunemaker-matchy>, ["~> 0.4.0"])
    s.add_dependency(%q<mocha>, ["~> 0.9.8"])
    s.add_dependency(%q<log_buddy>, [">= 0"])
  end
end
