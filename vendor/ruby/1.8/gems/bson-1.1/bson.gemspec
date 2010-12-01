require "./lib/bson"

Gem::Specification.new do |s|
  s.name = 'bson'

  s.version = BSON::VERSION

  s.platform = Gem::Platform::RUBY
  s.summary = 'Ruby implementation of BSON'
  s.description = 'A Ruby BSON implementation for MongoDB. For more information about Mongo, see http://www.mongodb.org. For more information on BSON, see http://www.bsonspec.org.'

  s.require_paths = ['lib']

  s.files  = ['Rakefile', 'bson.gemspec', 'LICENSE.txt']
  s.files += ['lib/bson.rb'] + Dir['lib/bson/**/*.rb']
  s.files += ['bin/b2json', 'bin/j2bson']
  s.files += Dir['ext/java/jar/**/*.jar']
  s.test_files = Dir['test/mongo_bson/*.rb']

  s.executables = ['b2json', 'j2bson']

  s.has_rdoc = true

  s.authors = ['Jim Menard', 'Mike Dirolf', 'Kyle Banker']
  s.email = 'mongodb-dev@googlegroups.com'
  s.homepage = 'http://www.mongodb.org'
end
