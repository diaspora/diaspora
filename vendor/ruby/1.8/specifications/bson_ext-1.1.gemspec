# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bson_ext}
  s.version = "1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Dirolf"]
  s.date = %q{2010-10-04}
  s.description = %q{C extensions to accelerate the Ruby BSON serialization. For more information about BSON, see http://bsonspec.org.  For information about MongoDB, see http://www.mongodb.org.}
  s.email = %q{mongodb-dev@googlegroups.com}
  s.extensions = ["ext/cbson/extconf.rb"]
  s.files = ["Rakefile", "bson_ext.gemspec", "ext/cbson/extconf.rb", "ext/cbson/buffer.c", "ext/cbson/cbson.c", "ext/cbson/encoding_helpers.c", "ext/cbson/buffer.h", "ext/cbson/encoding_helpers.h", "ext/cbson/version.h"]
  s.homepage = %q{http://www.mongodb.org}
  s.require_paths = ["ext"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{C extensions for Ruby BSON.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
