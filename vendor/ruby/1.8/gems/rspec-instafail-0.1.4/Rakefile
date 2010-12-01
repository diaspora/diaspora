task :default => :spec
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new {|t| t.spec_opts = ['--color --backtrace --debug']}

begin
  require 'jeweler'
  project_name = 'rspec-instafail'

  Jeweler::Tasks.new do |gem|
    gem.name = project_name
    gem.summary = "Show failing specs instantly"
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{project_name}"
    gem.authors = ["Michael Grosser"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end