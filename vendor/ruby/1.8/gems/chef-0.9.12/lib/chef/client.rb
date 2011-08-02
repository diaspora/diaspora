#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Copyright:: Copyright (c) 2008-2010 Opscode, Inc.
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

require 'chef/config'
require 'chef/mixin/params_validate'
require 'chef/log'
require 'chef/rest'
require 'chef/platform'
require 'chef/node'
require 'chef/role'
require 'chef/file_cache'
require 'chef/run_context'
require 'chef/runner'
require 'chef/cookbook/cookbook_collection'
require 'chef/cookbook/file_vendor'
require 'chef/cookbook/file_system_file_vendor'
require 'chef/cookbook/remote_file_vendor'
require 'chef/version'
require 'ohai'

class Chef
  # == Chef::Client
  # The main object in a Chef run. Preps a Chef::Node and Chef::RunContext,
  # syncs cookbooks if necessary, and triggers convergence.
  class Client

    # Clears all notifications for client run status events.
    # Primarily for testing purposes.
    def self.clear_notifications
      @run_start_notifications = nil
      @run_completed_successfully_notifications = nil
      @run_failed_notifications = nil
    end

    # The list of notifications to be run when the client run starts.
    def self.run_start_notifications
      @run_start_notifications ||= []
    end

    # The list of notifications to be run when the client run completes
    # successfully.
    def self.run_completed_successfully_notifications
      @run_completed_successfully_notifications ||= []
    end

    # The list of notifications to be run when the client run fails.
    def self.run_failed_notifications
      @run_failed_notifications ||= []
    end

    # Add a notification for the 'client run started' event. The notification
    # is provided as a block. The current Chef::RunStatus object will be passed
    # to the notification_block when the event is triggered.
    def self.when_run_starts(&notification_block)
      run_start_notifications << notification_block
    end

    # Add a notification for the 'client run success' event. The notification
    # is provided as a block. The current Chef::RunStatus object will be passed
    # to the notification_block when the event is triggered.
    def self.when_run_completes_successfully(&notification_block)
      run_completed_successfully_notifications << notification_block
    end

    # Add a notification for the 'client run failed' event. The notification
    # is provided as a block. The current Chef::RunStatus is passed to the
    # notification_block when the event is triggered.
    def self.when_run_fails(&notification_block)
      run_failed_notifications << notification_block
    end

    # Callback to fire notifications that the Chef run is starting
    def run_started
      self.class.run_start_notifications.each do |notification|
        notification.call(run_status)
      end
    end

    # Callback to fire notifications that the run completed successfully
    def run_completed_successfully
      self.class.run_completed_successfully_notifications.each do |notification|
        notification.call(run_status)
      end
    end

    # Callback to fire notifications that the Chef run failed
    def run_failed
      self.class.run_failed_notifications.each do |notification|
        notification.call(run_status)
      end
    end

    attr_accessor :node
    attr_accessor :ohai
    attr_accessor :rest
    attr_accessor :runner

    #--
    # TODO: timh/cw: 5-19-2010: json_attribs should be moved to RunContext?
    attr_reader :json_attribs

    attr_reader :run_status

    # Creates a new Chef::Client.
    def initialize(json_attribs=nil)
      @json_attribs = json_attribs
      @node = nil
      @run_status = nil
      @runner = nil
      @ohai = Ohai::System.new
    end
    
    # Do a full run for this Chef::Client.  Calls:
    #
    #  * run_ohai - Collect information about the system
    #  * build_node - Get the last known state, merge with local changes
    #  * register - If not in solo mode, make sure the server knows about this client
    #  * sync_cookbooks - If not in solo mode, populate the local cache with the node's cookbooks
    #  * converge - Bring this system up to date
    #
    # === Returns
    # true:: Always returns true.
    def run
      run_context = nil

      run_ohai
      register unless Chef::Config[:solo]
      build_node
      
      begin

        run_status.start_clock
        Chef::Log.info("Starting Chef Run (Version #{Chef::VERSION})")
        run_started
        
        if Chef::Config[:solo]
          Chef::Cookbook::FileVendor.on_create { |manifest| Chef::Cookbook::FileSystemFileVendor.new(manifest) }
          run_context = Chef::RunContext.new(node, Chef::CookbookCollection.new(Chef::CookbookLoader.new))
          run_status.run_context = run_context
          assert_cookbook_path_not_empty(run_context)
          converge(run_context)
        else
          # Sync_cookbooks eagerly loads all files except files and templates.
          # It returns the cookbook_hash -- the return result from
          # /nodes/#{nodename}/cookbooks -- which we will use for our
          # run_context.
          Chef::Cookbook::FileVendor.on_create { |manifest| Chef::Cookbook::RemoteFileVendor.new(manifest, rest) }
          cookbook_hash = sync_cookbooks
          run_context = Chef::RunContext.new(node, Chef::CookbookCollection.new(cookbook_hash))
          run_status.run_context = run_context

          assert_cookbook_path_not_empty(run_context)
          
          converge(run_context)
          Chef::Log.debug("Saving the current state of node #{node_name}")
          @node.save
        end
        
        run_status.stop_clock
        Chef::Log.info("Chef Run complete in #{run_status.elapsed_time} seconds")
        run_completed_successfully
        true
      rescue Exception => e
        run_status.stop_clock
        run_status.exception = e
        run_failed
        Chef::Log.debug("Re-raising exception: #{e.class} - #{e.message}\n#{e.backtrace.join("\n  ")}")
        raise
      ensure
        run_status = nil
      end
    end

    def run_ohai
      ohai.all_plugins
    end

    def node_name
      name = Chef::Config[:node_name] || ohai[:fqdn] || ohai[:hostname]
      Chef::Config[:node_name] = name

      unless name
        msg = "Unable to determine node name: configure node_name or configure the system's hostname and fqdn"
        raise Chef::Exceptions::CannotDetermineNodeName, msg
      end

      name
    end
    
    # Builds a new node object for this client.  Starts with querying for the FQDN of the current
    # host (unless it is supplied), then merges in the facts from Ohai.
    #
    # === Returns
    # node<Chef::Node>:: Returns the created node object, also stored in @node
    def build_node
      Chef::Log.debug("Building node object for #{@node_name}")

      if Chef::Config[:solo]
        @node = Chef::Node.build(node_name)
      else
        @node = Chef::Node.find_or_create(node_name)
      end


      @node.consume_external_attrs(ohai.data, @json_attribs)
      @node.expand!
      @node.save unless Chef::Config[:solo]
      @node.reset_defaults_and_overrides

      @run_status = Chef::RunStatus.new(@node)

      @node
    end

    # 
    # === Returns
    # rest<Chef::REST>:: returns Chef::REST connection object
    def register
      if File.exists?(Chef::Config[:client_key])
        Chef::Log.debug("Client key #{Chef::Config[:client_key]} is present - skipping registration")
      else
        Chef::Log.info("Client key #{Chef::Config[:client_key]} is not present - registering")
        Chef::REST.new(Chef::Config[:client_url], Chef::Config[:validation_client_name], Chef::Config[:validation_key]).register(node_name, Chef::Config[:client_key])
      end
      # We now have the client key, and should use it from now on.
      self.rest = Chef::REST.new(Chef::Config[:chef_server_url], node_name, Chef::Config[:client_key])
    end
    
    # Synchronizes all the cookbooks from the chef-server.
    #
    # === Returns
    # true:: Always returns true
    def sync_cookbooks
      Chef::Log.debug("Synchronizing cookbooks")
      cookbook_hash = rest.get_rest("nodes/#{node_name}/cookbooks")
      Chef::CookbookVersion.sync_cookbooks(cookbook_hash)

      # register the file cache path in the cookbook path so that CookbookLoader actually picks up the synced cookbooks
      Chef::Config[:cookbook_path] = File.join(Chef::Config[:file_cache_path], "cookbooks")
      
      cookbook_hash
    end
    
    # Converges the node.
    #
    # === Returns
    # true:: Always returns true
    def converge(run_context)
      Chef::Log.debug("Converging node #{node_name}")
      @runner = Chef::Runner.new(run_context)
      runner.converge
      true
    end
    
    private
    
    def directory_not_empty?(path)
      File.exists?(path) && (Dir.entries(path).size > 2)
    end
    
    def is_last_element?(index, object)
      object.kind_of?(Array) ? index == object.size - 1 : true 
    end  
    
    def assert_cookbook_path_not_empty(run_context)
      if Chef::Config[:solo]
        # Check for cookbooks in the path given
        # Chef::Config[:cookbook_path] can be a string or an array
        # if it's an array, go through it and check each one, raise error at the last one if no files are found
        Chef::Log.debug "loading from cookbook_path: #{Array(Chef::Config[:cookbook_path]).map { |path| File.expand_path(path) }.join(', ')}" 
        Array(Chef::Config[:cookbook_path]).each_with_index do |cookbook_path, index|
          if directory_not_empty?(cookbook_path)
            break
          else
            msg = "No cookbook found in #{Chef::Config[:cookbook_path].inspect}, make sure cookbook_path is set correctly."
            Chef::Log.fatal(msg)
            raise Chef::Exceptions::CookbookNotFound, msg if is_last_element?(index, Chef::Config[:cookbook_path])
          end
        end
      else
        Chef::Log.warn("Node #{node_name} has an empty run list.") if run_context.node.run_list.empty?
      end

    end
  end
end

