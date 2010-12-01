# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yui-compressor}
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Stephenson"]
  s.date = %q{2009-07-20}
  s.description = %q{A Ruby interface to YUI Compressor for minifying JavaScript and CSS assets.}
  s.email = %q{sstephenson@gmail.com}
  s.files = ["Rakefile", "lib/yui/compressor.rb", "test/compressor_test.rb", "vendor/yuicompressor-2.4.2.jar"]
  s.homepage = %q{http://github.com/sstephenson/ruby-yui-compressor/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{yui}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{JavaScript and CSS minification library}
  s.test_files = ["test/compressor_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
