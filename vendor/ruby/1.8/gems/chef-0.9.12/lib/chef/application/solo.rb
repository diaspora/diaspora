#
# Author:: AJ Christensen (<aj@opscode.com>)
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

require 'chef'
require 'chef/application'
require 'chef/client'
require 'chef/config'
require 'chef/daemon'
require 'chef/log'
require 'chef/rest'
require 'open-uri'
require 'fileutils'

class Chef::Application::Solo < Chef::Application
  
  option :config_file, 
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => "/etc/chef/solo.rb",
    :description => "The configuration file to use"

  option :log_level, 
    :short        => "-l LEVEL",
    :long         => "--log_level LEVEL",
    :description  => "Set the log level (debug, info, warn, error, fatal)",
    :proc         => lambda { |l| l.to_sym }

  option :log_location,
    :short        => "-L LOGLOCATION",
    :long         => "--logfile LOGLOCATION",
    :description  => "Set the log file location, defaults to STDOUT",
    :proc         => nil

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

  option :interval,
    :short => "-i SECONDS",
    :long => "--interval SECONDS",
    :description => "Run chef-client periodically, in seconds",
    :proc => lambda { |s| s.to_i }

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

  option :recipe_url,
      :short => "-r RECIPE_URL",
      :long => "--recipe-url RECIPE_URL",
      :description => "Pull down a remote gzipped tarball of recipes and untar it to the cookbook cache.",
      :proc => nil
  
  option :version,
    :short        => "-v",
    :long         => "--version",
    :description  => "Show chef version",
    :boolean      => true,
    :proc         => lambda {|v| puts "Chef: #{::Chef::VERSION}"},
    :exit         => 0

  def initialize
    super
    @chef_solo = nil
    @chef_solo_json = nil
  end
  
  def reconfigure
    super
    
    Chef::Config[:solo] = true

    if Chef::Config[:daemonize]
      Chef::Config[:interval] ||= 1800
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
        @chef_solo_json = JSON.parse(json_io.read)
        json_io.close unless json_io.closed?
      rescue JSON::ParserError => error
        Chef::Application.fatal!("Could not parse the provided JSON file (#{Chef::Config[:json_attribs]})!: " + error.message, 2)
      end
    end
    
    if Chef::Config[:recipe_url]
      cookbooks_path = Array(Chef::Config[:cookbook_path]).detect{|e| e =~ /\/cookbooks\/*$/ }
      recipes_path = File.expand_path(File.join(cookbooks_path, '..'))
      target_file = File.join(recipes_path, 'recipes.tgz')

      Chef::Log.debug "Creating path #{recipes_path} to extract recipes into"
      FileUtils.mkdir_p recipes_path
      path = File.join(recipes_path, 'recipes.tgz')
      File.open(path, 'wb') do |f|
        open(Chef::Config[:recipe_url]) do |r|
          f.write(r.read)
        end
      end
      Chef::Mixin::Command.run_command(:command => "tar zxvfC #{path} #{recipes_path}")
    end
  end
  
  def setup_application
    Chef::Daemon.change_privilege
  end
  
  def run_application
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

        @chef_solo = Chef::Client.new(@chef_solo_json)
        @chef_solo.run
        @chef_solo = nil
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
          Chef::Log.error("#{e.class}")
          Chef::Log.fatal("#{e}\n#{e.backtrace.join("\n")}")
          Chef::Log.fatal("Sleeping for #{Chef::Config[:interval]} seconds before trying again")
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
