#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

begin
namespace :integration do
  desc "rebuild and prepare test db"
  task :gogogo => ['db:integration:prepare', :start_servers, :run_specs]

  task :start_servers => :environment do
    abcs = ActiveRecord::Base.configurations
    envs = abcs.keys.select{ |k| k.include?("integration") }
    if servers_active?(envs.map{ |env| abcs[env]["app_server_port"] })
      puts "Servers are already running, using running integration servers."
      next
    end
    $integration_server_pids = []
    envs.each do |env|
      $integration_server_pids << fork do
        Process.exec "thin start -e #{env} -p #{abcs[env]["app_server_port"]}"
      end
    end
    while(!servers_active?(envs.map{ |env| abcs[env]["app_server_port"] })) do
      sleep(1)
    end
  end

  task :run_servers => :start_servers do
    while(true) do
      sleep 1000
    end
  end

  require 'rspec/core'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:run_specs => :start_servers) do |t|
    t.pattern = "./spec/multi_server/**/*_spec.rb"
  end

  def servers_active? ports
    begin
      ports.each { |port| RestClient.get("localhost:#{port}/users/sign_in") }
      true
    rescue
      false
    end
  end

end
rescue MissingSourceFile
end
