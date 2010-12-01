# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/core/version"

Gem::Specification.new do |s|
  s.name        = "rspec-core"
  s.version     = RSpec::Core::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chad Humphries", "David Chelimsky"]
  s.email       = "dchelimsky@gmail.com;chad.humphries@gmail.com"
  s.homepage    = "http://github.com/rspec/rspec-core"
  s.summary     = "rspec-core-#{RSpec::Core::Version::STRING}"
  s.description = "RSpec runner and example groups"

  s.rubygems_version   = "1.3.7"
  s.rubyforge_project  = "rspec"
  s.default_executable = "rspec"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [ "README.markdown" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.post_install_message = %Q{**************************************************

  Thank you for installing #{s.summary}

  Please be sure to look at the upgrade instructions to see what might have
  changed since the last release:

  http://github.com/rspec/rspec-core/blob/master/Upgrade.markdown

**************************************************
}
end

