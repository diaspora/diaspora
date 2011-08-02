# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/rails/version"

Gem::Specification.new do |s|
  s.name        = "rspec-rails"
  s.version     = RSpec::Rails::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Chelimsky"]
  s.email       = "dchelimsky@gmail.com"
  s.homepage    = "http://github.com/rspec/rspec-rails"
  s.summary     = "rspec-rails-#{RSpec::Rails::Version::STRING}"
  s.description = "RSpec-2 for Rails-3"

  s.rubygems_version   = "1.3.7"
  s.rubyforge_project  = "rspec"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [ "README.md" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_runtime_dependency(%q<activesupport>, ["~> 3.0"])
  s.add_runtime_dependency(%q<actionpack>, ["~> 3.0"])
  s.add_runtime_dependency(%q<railties>, ["~> 3.0"])
  # if RSpec::Rails::Version::STRING =~ /[a-zA-Z]+/
    # s.add_runtime_dependency "rspec", "= #{RSpec::Rails::Version::STRING}"
  # else
    s.add_runtime_dependency "rspec", "~> #{RSpec::Rails::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
  # end
end

