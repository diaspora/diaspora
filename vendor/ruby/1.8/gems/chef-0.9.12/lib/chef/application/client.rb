#
# Author:: AJ Christensen (<aj@opscode.com)
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'chef/application'
require 'chef/client'
require 'chef/config'
require 'chef/daemon'
require 'chef/log'
require 'chef/rest'


class Chef::Application::Client < Chef::Application
  
  option :config_file, 
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => "/etc/chef/client.rb",
    :description => "The configuration file to use"

  option :log_level, 
    :short        => "-l LEVEL",
    :long         => "--log_level LEVEL",
    :description  => "Set the log level (debug, info, warn, error, fatal)",
    :proc         => lambda { |l| l.to_sym }

  option :log_location,
    :short        => "-L LOGLOCATION",
    :long         => "--logfile LOGLOCATION",
    :description  => "Set the log file location, defaults to STDOUT - recommended for daemonizing",
    :proc         => nil

  option :verbose_logging,
    :short        => "-V",
    :long         => "--verbose",
    :description  => "Ensures logging goes to STDOUT as well as to other configured log location(s).",
    :proc         => lambda { |p| true }

  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :on           => :tail,
    :boolean      => true,
    :show_options => true,
    :exit         => 0
    
  option :user,
    :short => "-u USER",
    :long => "--user USER",
    :description => "User to set privilege to",
    :proc => nil

  option :group,
    :short => "-g GROUP",
    :long => "--group GROUP",
    :description => "Group to set privilege to",
    :proc => nil

  option :daemonize,
    :short => "-d",
    :long => "--daemonize",
    :description => "Daemonize the process",
    :proc => lambda { |p| true }

  option :pid_file,
    :short        => "-P PID_FILE",
    :long         => "--pid PIDFILE",
    :description  => "Set the PID file location, defaults to /tmp/chef-client.pid",
    :proc         => nil

  option :interval,
    :short => "-i SECONDS",
    :long => "--interval SECONDS",
    :description => "Run chef-client periodically, in seconds",
    :proc => lambda { |s| s.to_i }

  option :once,
    :long => "--short",
    :description => "Cancel any interval or splay options, run chef once and exit",
    :boolean => true

  option :json_attribs,
    :short => "-j JSON_ATTRIBS",
    :long => "--json-attributes JSON_ATTRIBS",
    :description => "Load attributes from a JSON file or URL",
    :proc => nil

  option :node_name,
    :short => "-N NODE_NAME",
    :long => "--node-name NODE_NAME",
    :description => "The node name for this client",
    :proc => nil

  option :splay,
    :short => "-s SECONDS",
    :long => "--splay SECONDS",
    :description => "The splay time for running at intervals, in seconds",
    :proc => lambda { |s| s.to_i }

  option :chef_server_url,
    :short => "-S CHEFSERVERURL",
    :long => "--server CHEFSERVERURL",
    :description => "The chef server URL",
    :proc => nil

  option :validation_key,
    :short        => "-K KEY_FILE",
    :long         => "--validation_key KEY_FILE",
    :description  => "Set the validation key file location, used for registering new clients",
    :proc         => nil

  option :client_key,
    :short        => "-k KEY_FILE",
    :long         => "--client_key KEY_FILE",
    :description  => "Set the client key file location",
    :proc         => nil

  option :version,
    :short        => "-v",
    :long         => "--version",
    :description  => "Show chef version",
    :boolean      => true,
    :proc         => lambda {|v| puts "Chef: #{::Chef::VERSION}"},
    :exit         => 0

  def initialize
    super

    @chef_client = nil
    @chef_client_json = nil
  end
  
  # Reconfigure the chef client
  # Re-open the JSON attributes and load them into the node
  def reconfigure 
    super 

    Chef::Config[:chef_server_url] = config[:chef_server_url] if config.has_key? :chef_server_url
   
    if Chef::Config[:daemonize]
      Chef::Config[:interval] ||= 1800
    end

    if Chef::Config[:once]
      Chef::Config[:interval] = nil
      Chef::Config[:splay] = nil
    end

    if Chef::Config[:json_attribs]
      begin
        json_io = case Chef::Config[:json_attribs]
                  when /^(http|https):\/\//
                    @rest = Chef::REST.new(Chef::Config[:json_attribs], nil, nil)
                    @rest.get_rest(Chef::Config[:json_attribs], true).open
                  else
                    open(Chef::Config[:json_attribs])
                  end
      rescue SocketError => error
        Chef::Application.fatal!("I cannot connect to #{Chef::Config[:json_attribs]}", 2)
      rescue Errno::ENOENT => error
        Chef::Application.fatal!("I cannot find #{Chef::Config[:json_attribs]}", 2)
      rescue Errno::EACCES => error
        Chef::Application.fatal!("Permissions are incorrect on #{Chef::Config[:json_attribs]}. Please chmod a+r #{Chef::Config[:json_attribs]}", 2)
      rescue Exception => error
        Chef::Application.fatal!("Got an unexpected error reading #{Chef::Config[:json_attribs]}: #{error.message}", 2)
      end

      begin
        @chef_client_json = JSON.parse(json_io.read)
        json_io.close unless json_io.closed?
      rescue JSON::ParserError => error
        Chef::Application.fatal!("Could not parse the provided JSON file (#{Chef::Config[:json_attribs]})!: " + error.message, 2)
      end
    end
  end

  def configure_logging
    super
    Chef::Log.verbose = Chef::Config[:verbose_logging]
    Mixlib::Authentication::Log.logger = Ohai::Log.logger = Chef::Log.logger
  end
  
  def setup_application
    Chef::Daemon.change_privilege
  end
  
  # Run the chef client, optionally daemonizing or looping at intervals.
  def run_application
    if Chef::Config[:version]
      puts "Chef version: #{::Chef::VERSION}"
    end

    if Chef::Config[:daemonize]
      Chef::Daemon.daemonize("chef-client")
    end
    
    loop do
      begin
        if Chef::Config[:splay]
          splay = rand Chef::Config[:splay]
          Chef::Log.debug("Splay sleep #{splay} seconds")
          sleep splay
        end
        @chef_client = Chef::Client.new(@chef_client_json)
        @chef_client_json = nil

        @chef_client.run
        @chef_client = nil
        if Chef::Config[:interval]
          Chef::Log.debug("Sleeping for #{Chef::Config[:interval]} seconds")
          sleep Chef::Config[:interval]
        else
          Chef::Application.exit! "Exiting", 0
        end
      rescue SystemExit => e
        raise
      rescue Exception => e
        if Chef::Config[:interval]
          Chef::Log.error("#{e.class}:#{e}\n#{e.backtrace.join("\n")}")
          Chef::Log.error("Sleeping for #{Chef::Config[:interval]} seconds before trying again")
          sleep Chef::Config[:interval]
          retry
        else
          raise
        end
      ensure
        GC.start
      end
    end
  end
end
