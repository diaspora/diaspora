require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "pubsubhubbub"
    gemspec.summary = "Asynchronous PubSubHubbub client for Ruby"
    gemspec.description = gemspec.summary
    gemspec.email = "ilya@igvita.com"
    gemspec.homepage = "http://github.com/igrigorik/pubsubhubbub"
    gemspec.authors = ["Ilya Grigorik"]
    gemspec.add_dependency('eventmachine', '>= 0.12.9')
    gemspec.add_dependency('em-http-request', '>= 0.1.5')
    gemspec.rubyforge_project = "pubsubhubbub"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
