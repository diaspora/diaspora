#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
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

require 'chef/resource_collection'
require 'chef/node'
require 'chef/role'
require 'chef/log'
require 'chef/mixin/language_include_recipe'

class Chef
  # == Chef::RunContext
  # Value object that loads and tracks the context of a Chef run
  class RunContext

    # Used to load the node's recipes after expanding its run list
    include Chef::Mixin::LanguageIncludeRecipe

    attr_reader :node, :cookbook_collection, :definitions

    # Needs to be settable so deploy can run a resource_collection independent
    # of any cookbooks.
    attr_accessor :resource_collection

    # Creates a new Chef::RunContext object and populates its fields. This object gets
    # used by the Chef Server to generate a fully compiled recipe list for a node.
    #
    # === Returns
    # object<Chef::RunContext>:: Duh. :)
    def initialize(node, cookbook_collection)
      @node = node
      @cookbook_collection = cookbook_collection
      @resource_collection = Chef::ResourceCollection.new
      @definitions = Hash.new
      
      # TODO: 5/18/2010 cw/timh - See note on Chef::Node's
      # cookbook_collection attr_accessor
      node.cookbook_collection = cookbook_collection

      load
    end

    def load
      foreach_cookbook_load_segment(:libraries) do |cookbook_name, filename|
        Chef::Log.debug("Loading cookbook #{cookbook_name}'s library file: #{filename}")
        require filename
      end
      
      foreach_cookbook_load_segment(:providers) do |cookbook_name, filename|
        Chef::Log.debug("Loading cookbook #{cookbook_name}'s providers from #{filename}")
        Chef::Provider.build_from_file(cookbook_name, filename)
      end
      
      foreach_cookbook_load_segment(:resources) do |cookbook_name, filename|
        Chef::Log.debug("Loading cookbook #{cookbook_name}'s resources from #{filename}")
        Chef::Resource.build_from_file(cookbook_name, filename)
      end

      node.load_attributes

      foreach_cookbook_load_segment(:definitions) do |cookbook_name, filename|
        Chef::Log.debug("Loading cookbook #{cookbook_name}'s definitions from #{filename}")
        resourcelist = Chef::ResourceDefinitionList.new
        resourcelist.from_file(filename)
        definitions.merge!(resourcelist.defines) do |key, oldval, newval|
          Chef::Log.info("Overriding duplicate definition #{key}, new found in #{filename}")
          newval
        end
      end

      # Retrieve the fully expanded list of recipes for the node by
      # resolving roles; this step also merges attributes into the
      # node from the roles/recipes included.
      recipe_names = node.expand!

      recipe_names.each do |recipe_name|
        # TODO: timh/cw, 5-14-2010: It's distasteful to be including
        # the DSL in a class outside the context of the DSL
        include_recipe(recipe_name)
      end
    end

    private
    
    def foreach_cookbook_load_segment(segment, &block)
      cookbook_collection.each do |cookbook_name, cookbook|
        segment_filenames = cookbook.segment_filenames(segment)
        segment_filenames.each do |segment_filename|
          block.call(cookbook_name, segment_filename)
        end
      end
    end
    
  end
end
