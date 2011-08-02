# run unit tests for the NewRelic Agent
namespace :newrelic do
  desc "install a default config/newrelic.yml file"
  task :install do
    load File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "install.rb"))  
  end
end