# run unit tests for the NewRelic Agent
begin
  require 'rake/test_task'
rescue LoadError => e
end

if defined? Rake::TestTask
  namespace :test do
    AGENT_HOME = File.expand_path(File.join(File.dirname(__FILE__), "..",".."))
    Rake::TestTask.new(:newrelic) do |t|
      t.libs << "#{AGENT_HOME}/test"
      t.libs << "#{AGENT_HOME}/lib"
      t.pattern = "#{AGENT_HOME}/test/**/*_test.rb"
      t.verbose = true
    end
    Rake::Task['test:newrelic'].comment = "Run the unit tests for the Agent"
    task :newrelic => :environment
  end
end
