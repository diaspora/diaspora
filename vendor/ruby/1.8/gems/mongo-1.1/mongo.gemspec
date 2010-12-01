require "./lib/mongo"

Gem::Specification.new do |s|
  s.name = 'mongo'

  s.version = Mongo::VERSION

  s.platform = Gem::Platform::RUBY
  s.summary = 'Ruby driver for the MongoDB'
  s.description = 'A Ruby driver for MongoDB. For more information about Mongo, see http://www.mongodb.org.'

  s.require_paths = ['lib']

  s.files  = ['README.rdoc', 'HISTORY', 'Rakefile',
    'mongo.gemspec', 'LICENSE.txt']
  s.files += ['lib/mongo.rb'] + Dir['lib/mongo/**/*.rb']
  s.files += Dir['examples/**/*.rb'] + Dir['bin/**/*.rb']
  s.files += Dir['bin/mongo_console']
  s.test_files = Dir['test/**/*.rb']

  s.executables = ['mongo_console']

  s.has_rdoc = true
  s.test_files = Dir['test/**/*.rb']
  s.test_files -= Dir['test/mongo_bson/*.rb'] # remove these files from the manifest

  s.has_rdoc = true
  s.rdoc_options = ['--main', 'README.rdoc', '--inline-source']
  s.extra_rdoc_files = ['README.rdoc']

  s.authors = ['Jim Menard', 'Mike Dirolf', 'Kyle Banker']
  s.email = 'mongodb-dev@googlegroups.com'
  s.homepage = 'http://www.mongodb.org'

  s.add_dependency(%q<bson>, [">= 1.0.5"])
end
