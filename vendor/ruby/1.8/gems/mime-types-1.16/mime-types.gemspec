# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mime-types}
  s.version = "1.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin Ziegler"]
  s.cert_chain = ["/Users/austin/.gem/gem-public_cert.pem"]
  s.date = %q{2009-03-01}
  s.description = %q{MIME::Types for Ruby originally based on and synchronized with MIME::Types for Perl by Mark Overmeer, copyright 2001 - 2009. As of version 1.15, the data format for the MIME::Type list has changed and the synchronization will no longer happen.}
  s.email = ["austin@rubyforge.org"]
  s.extra_rdoc_files = ["History.txt", "Install.txt", "Licence.txt", "README.txt"]
  s.files = ["History.txt", "Install.txt", "Licence.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/mime/types.rb", "lib/mime/types.rb.data", "setup.rb", "test/test_mime_type.rb", "test/test_mime_types.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://mime-types.rubyforge.org/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mime-types}
  s.rubygems_version = %q{1.3.1}
  s.signing_key = %q{/Users/austin/.gem/gem-private_key.pem}
  s.summary = %q{Manages a MIME Content-Type database that will return the Content-Type for a given filename.}
  s.test_files = ["test/test_mime_type.rb", "test/test_mime_types.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<archive-tar-minitar>, ["~> 0.5.1"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.2.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<archive-tar-minitar>, ["~> 0.5.1"])
      s.add_dependency(%q<nokogiri>, ["~> 1.2.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<archive-tar-minitar>, ["~> 0.5.1"])
    s.add_dependency(%q<nokogiri>, ["~> 1.2.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end
