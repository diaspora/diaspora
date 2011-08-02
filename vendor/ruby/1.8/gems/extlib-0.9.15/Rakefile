require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'extlib'
    gem.summary     = 'Support library for DataMapper and Merb'
    gem.description = gem.summary
    gem.email       = 'dan.kubb@gmail.com'
    gem.homepage    = 'http://github.com/datamapper/extlib'
    gem.authors     = [ 'Dan Kubb' ]

    gem.rubyforge_project = 'extlib'

    gem.add_development_dependency 'json_pure', '~> 1.4'
    gem.add_development_dependency 'rspec',     '~> 1.3'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| load task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
