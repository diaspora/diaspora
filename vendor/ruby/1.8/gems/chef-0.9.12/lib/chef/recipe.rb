#--
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Copyright:: Copyright (c) 2008, 2009 Opscode, Inc.
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


require 'chef/mixin/recipe_definition_dsl_core'
require 'chef/mixin/from_file'
require 'chef/mixin/language'
require 'chef/mixin/language_include_recipe'

require 'chef/mixin/deprecation'

class Chef
  # == Chef::Recipe
  # A Recipe object is the context in which Chef recipes are evaluated.
  class Recipe
    
    include Chef::Mixin::FromFile
    include Chef::Mixin::Language
    include Chef::Mixin::LanguageIncludeRecipe
    include Chef::Mixin::RecipeDefinitionDSLCore
    include Chef::Mixin::Deprecation
    
    attr_accessor :cookbook_name, :recipe_name, :recipe, :params, :run_context

    # Parses a potentially fully-qualified recipe name into its
    # cookbook name and recipe short name.
    #
    # For example:
    #   "aws::elastic_ip" returns [:aws, "elastic_ip"]
    #   "aws" returns [:aws, "default"]
    #--
    # TODO: Duplicates functionality of RunListItem
    def self.parse_recipe_name(recipe_name)
      rmatch = recipe_name.match(/(.+?)::(.+)/)
      if rmatch
        [ rmatch[1].to_sym, rmatch[2] ]
      else
        [ recipe_name.to_sym, "default" ]
      end
    end

    def initialize(cookbook_name, recipe_name, run_context)
      @cookbook_name = cookbook_name
      @recipe_name = recipe_name
      @run_context = run_context
      # TODO: 5/19/2010 cw/tim: determine whether this can be removed
      @params = Hash.new
      @node = deprecated_ivar(run_context.node, :node, :warn)
    end
    
    # Used in DSL mixins
    def node
      run_context.node
    end
    
    # Used by the DSL to look up resources when executing in the context of a
    # recipe.
    #--
    # what does this do? and what is args? TODO 5-14-2010.
    def resources(*args)
      run_context.resource_collection.find(*args)
    end
    
    # Sets a tag, or list of tags, for this node.  Syntactic sugar for
    # run_context.node[:tags].
    #
    # With no arguments, returns the list of tags.
    #
    # === Parameters
    # tags<Array>:: A list of tags to add - can be a single string
    #
    # === Returns
    # tags<Array>:: The contents of run_context.node[:tags]
    def tag(*tags)
      if tags.length > 0
        tags.each do |tag|
          run_context.node[:tags] << tag unless run_context.node[:tags].include?(tag)
        end
        run_context.node[:tags]
      else
        run_context.node[:tags]
      end
    end
    
    # Returns true if the node is tagged with *all* of the supplied +tags+.
    #
    # === Parameters
    # tags<Array>:: A list of tags
    #
    # === Returns
    # true<TrueClass>:: If all the parameters are present
    # false<FalseClass>:: If any of the parameters are missing
    def tagged?(*tags)
      tags.each do |tag|
        return false unless run_context.node[:tags].include?(tag)
      end
      true
    end
    
    # Removes the list of tags from the node.
    #
    # === Parameters
    # tags<Array>:: A list of tags
    #
    # === Returns
    # tags<Array>:: The current list of run_context.node[:tags]
    def untag(*tags)
      tags.each do |tag|
        run_context.node[:tags].delete(tag)
      end
    end
    
  end
end
