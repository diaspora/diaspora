# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-hmac}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daiki Ueno", "Geoffrey Grosenbach"]
  s.date = %q{2010-01-20}
  s.description = %q{This module provides common interface to HMAC functionality. HMAC is a kind of "Message Authentication Code" (MAC) algorithm whose standard is documented in RFC2104. Namely, a MAC provides a way to check the integrity of information transmitted over or stored in an unreliable medium, based on a secret key.

Originally written by Daiki Ueno. Converted to a RubyGem by Geoffrey Grosenbach}
  s.email = ["", "boss@topfunky.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/hmac-md5.rb", "lib/hmac-rmd160.rb", "lib/hmac-sha1.rb", "lib/hmac-sha2.rb", "lib/hmac.rb", "lib/ruby_hmac.rb", "test/test_hmac.rb"]
  s.homepage = %q{http://ruby-hmac.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-hmac}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{This module provides common interface to HMAC functionality}
  s.test_files = ["test/test_hmac.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.3"])
      s.add_development_dependency(%q<gemcutter>, [">= 0.2.1"])
      s.add_development_dependency(%q<hoe>, [">= 2.5.0"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.3"])
      s.add_dependency(%q<gemcutter>, [">= 0.2.1"])
      s.add_dependency(%q<hoe>, [">= 2.5.0"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.3"])
    s.add_dependency(%q<gemcutter>, [">= 0.2.1"])
    s.add_dependency(%q<hoe>, [">= 2.5.0"])
  end
end
