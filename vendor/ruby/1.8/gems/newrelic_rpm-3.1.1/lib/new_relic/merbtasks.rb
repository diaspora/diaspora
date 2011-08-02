namespace :newrelic do
  desc "Install the developer mode newrelic.yml file"
  task :default do
    load File.expand_path(File.join(__FILE__,"..","..","install.rb"))
  end
end
