#--
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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
#

require 'chef/recipe'
require 'chef/run_context'
require 'chef/config'
require 'chef/client'
require 'chef/cookbook/cookbook_collection'
require 'chef/cookbook_loader'

module Shef
  class ShefSession
    include Singleton
    
    def self.session_type(type=nil)
      @session_type = type if type
      @session_type
    end

    attr_accessor :node, :compile, :recipe, :run_context
    attr_reader :node_attributes, :client
    def initialize
      @node_built = false
    end
    
    def node_built?
      !!@node_built
    end
    
    def reset!
      loading do 
        rebuild_node
        @node = client.node
        shorten_node_inspect
        Shef::Extensions.extend_context_node(@node)
        rebuild_context
        node.consume_attributes(node_attributes) if node_attributes
        @recipe = Chef::Recipe.new(nil, nil, run_context)
        Shef::Extensions.extend_context_recipe(@recipe)
        @node_built = true
      end
    end
    
    def node_attributes=(attrs)
      @node_attributes = attrs
      @node.consume_attributes(@node_attributes)
    end
    
    def resource_collection
      run_context.resource_collection
    end

    def run_context
      @run_context || rebuild_context
    end
    
    def definitions
      nil
    end
    
    def cookbook_loader
      nil
    end
    
    def save_node
      raise "Not Supported! #{self.class.name} doesn't support #save_node, maybe you need to run shef in client mode?"
    end
    
    def rebuild_context
      raise "Not Implemented! :rebuild_collection should be implemented by subclasses"
    end
    
    private
    
    def loading
      show_loading_progress
      begin
        yield
      rescue => e
        loading_complete(false)
        raise e
      else
        loading_complete(true)
      end
    end
    
    def show_loading_progress
      print "Loading"
      @loading = true
      @dot_printer = Thread.new do
        while @loading
          print "."
          sleep 0.5
        end
      end
    end
    
    def loading_complete(success)
      @loading = false
      @dot_printer.join
      msg = success ? "done.\n\n" : "epic fail!\n\n"
      print msg
    end
    
    def shorten_node_inspect
      def @node.inspect
        "<Chef::Node:0x#{self.object_id.to_s(16)} @name=\"#{self.name}\">"
      end
    end
    
    def rebuild_node
      raise "Not Implemented! :rebuild_node should be implemented by subclasses"
    end
 
  end
  
  class StandAloneSession < ShefSession

    session_type :standalone
    
    def rebuild_context
      @run_context = Chef::RunContext.new(@node, {}) # no recipes
    end
    
    private
    
    def rebuild_node
      Chef::Config[:solo] = true
      @client = Chef::Client.new
      @client.run_ohai
      @client.build_node
    end
    
  end
  
  class SoloSession < ShefSession

    session_type :solo
    
    def definitions
      @run_context.definitions
    end
    
    def rebuild_context
      @run_context = Chef::RunContext.new(@node, Chef::CookbookCollection.new(Chef::CookbookLoader.new))
    end
    
    private
    
    def rebuild_node
      # Tell the client we're chef solo so it won't try to contact the server
      Chef::Config[:solo] = true
      @client = Chef::Client.new
      @client.run_ohai
      @client.build_node
    end
    
  end
  
  class ClientSession < SoloSession

    session_type :solo
    
    def save_node
      @client.save_node
    end
    
    private

    def rebuild_node
      # Make sure the client knows this is not chef solo
      Chef::Config[:solo] = false
      @client = Chef::Client.new
      @client.run_ohai
      @client.register
      @client.build_node
      
      @client.sync_cookbooks
    end

  end

  class DoppelGangerClient < Chef::Client

    attr_reader :node_name

    def initialize(node_name)
      @node_name = node_name
      @ohai = Ohai::System.new
    end

    # Run the very smallest amount of ohai we can get away with and still
    # hope to have things work. Otherwise we're not very good doppelgangers
    def run_ohai
      @ohai.require_plugin('os')
    end

    # DoppelGanger implementation of build_node. preserves as many of the node's
    # attributes, and does not save updates to the server
    def build_node
      Chef::Log.debug("Building node object for #{@node_name}")

      @node = Chef::Node.find_or_create(node_name)

      ohai_data = @ohai.data.merge(@node.automatic_attrs)

      @node.consume_external_attrs(ohai_data,nil)
      @node.reset_defaults_and_overrides

      @node
    end

    def register
      @rest = Chef::REST.new(Chef::Config[:chef_server_url], Chef::Config[:node_name], Chef::Config[:client_key])
    end

  end

  class DoppelGangerSession < ClientSession

    session_type "doppelganger client"

    def save_node
      puts "A doppelganger should think twice before saving the node"
    end

    def assume_identity(node_name)
      Chef::Config[:doppelganger] = @node_name = node_name
      reset!
    rescue Exception => e
      puts "#{e.class.name}: #{e.message}"
      puts Array(e.backtrace).join("\n")
      puts
      puts "* " * 40
      puts "failed to assume the identity of node '#{node_name}', resetting"
      puts "* " * 40
      puts
      Chef::Config[:doppelganger] = false
      @node_built = false
      Shef.session
    end

    def rebuild_node
      # Make sure the client knows this is not chef solo
      Chef::Config[:solo] = false
      @client = DoppelGangerClient.new(@node_name)
      @client.run_ohai
      @client.register
      @client.build_node

      @client.sync_cookbooks
    end

  end

end
