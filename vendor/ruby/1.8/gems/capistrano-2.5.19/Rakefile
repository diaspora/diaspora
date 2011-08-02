require "./lib/capistrano/version"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.version
    gem.name            = "capistrano"
    gem.executables     = %W(capify cap)
    gem.summary         = %Q{Capistrano – Welcome to easy deployment with Ruby over SSH}
    gem.description     = %Q{Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH.}
    gem.homepage        = "http://github.com/capistrano/capistrano"
    gem.email           = [ "jamis@jamisbuck.org", "lee.hambley@gmail.com" ]
    gem.authors         = [ "Jamis Buck", "Lee Hambley" ]
    gem.add_dependency  "net-ssh",          ">=2.0.14"
    gem.add_dependency  "net-sftp",         ">=2.0.0"
    gem.add_dependency  "net-scp",          ">=1.0.0"
    gem.add_dependency  "net-ssh-gateway",  ">=1.0.0"
    gem.add_dependency  "highline"
    gem.add_development_dependency "mocha", ">= 0"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :test => :check_dependencies
task :default => :test

