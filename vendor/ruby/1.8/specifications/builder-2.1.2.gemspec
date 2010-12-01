# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{builder}
  s.version = "2.1.2"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Weirich"]
  s.autorequire = %q{builder}
  s.cert_chain = nil
  s.date = %q{2007-06-15}
  s.description = %q{Builder provides a number of builder objects that make creating structured data simple to do.  Currently the following builder objects are supported:  * XML Markup * XML Events}
  s.email = %q{jim@weirichhouse.org}
  s.extra_rdoc_files = ["CHANGES", "Rakefile", "README", "doc/releases/builder-1.2.4.rdoc", "doc/releases/builder-2.0.0.rdoc", "doc/releases/builder-2.1.1.rdoc"]
  s.files = ["lib/blankslate.rb", "lib/builder.rb", "lib/builder/blankslate.rb", "lib/builder/xchar.rb", "lib/builder/xmlbase.rb", "lib/builder/xmlevents.rb", "lib/builder/xmlmarkup.rb", "test/performance.rb", "test/preload.rb", "test/test_xchar.rb", "test/testblankslate.rb", "test/testeventbuilder.rb", "test/testmarkupbuilder.rb", "scripts/publish.rb", "CHANGES", "Rakefile", "README", "doc/releases/builder-1.2.4.rdoc", "doc/releases/builder-2.0.0.rdoc", "doc/releases/builder-2.1.1.rdoc"]
  s.homepage = %q{http://onestepback.org}
  s.rdoc_options = ["--title", "Builder -- Easy XML Building", "--main", "README", "--line-numbers"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Builders for MarkUp.}
  s.test_files = ["test/test_xchar.rb", "test/testblankslate.rb", "test/testeventbuilder.rb", "test/testmarkupbuilder.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
