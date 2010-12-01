#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
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
#

require 'chef/config'
require 'chef/cookbook/cookbook_collection'
require 'chef/mixin/check_helper'
require 'chef/mixin/params_validate'
require 'chef/mixin/from_file'
require 'chef/mixin/language_include_attribute'
require 'chef/mixin/deep_merge'
require 'chef/couchdb'
require 'chef/rest'
require 'chef/run_list'
require 'chef/node/attribute'
require 'chef/index_queue'
require 'extlib'
require 'json'

class Chef
  class Node
    
    attr_accessor :recipe_list, :couchdb, :couchdb_rev, :run_state, :run_list
    attr_accessor :override_attrs, :default_attrs, :normal_attrs, :automatic_attrs
    attr_reader :couchdb_id
    
    # TODO: 5/18/2010 cw/timh. cookbook_collection should be removed
    # from here and for any place it's needed, it should be accessed
    # through a Chef::RunContext
    attr_accessor :cookbook_collection

    include Chef::Mixin::CheckHelper
    include Chef::Mixin::FromFile
    include Chef::Mixin::ParamsValidate
    include Chef::Mixin::LanguageIncludeAttribute
    include Chef::IndexQueue::Indexable

    DESIGN_DOCUMENT = {
      "version" => 9,
      "language" => "javascript",
      "views" => {
        "all" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "node") {
              emit(doc.name, doc);
            }
          }
          EOJS
        },
        "all_id" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "node") {
              emit(doc.name, doc.name);
            }
          }
          EOJS
        },
        "status" => {
          "map" => <<-EOJS
            function(doc) {
              if (doc.chef_type == "node") {
                var to_emit = { "name": doc.name };
                if (doc["attributes"]["fqdn"]) {
                  to_emit["fqdn"] = doc["attributes"]["fqdn"];
                } else {
                  to_emit["fqdn"] = "Undefined";
                }
                if (doc["attributes"]["ipaddress"]) {
                  to_emit["ipaddress"] = doc["attributes"]["ipaddress"];
                } else {
                  to_emit["ipaddress"] = "Undefined";
                }
                if (doc["attributes"]["ohai_time"]) {
                  to_emit["ohai_time"] = doc["attributes"]["ohai_time"];
                } else {
                  to_emit["ohai_time"] = "Undefined";
                }
                if (doc["attributes"]["uptime"]) {
                  to_emit["uptime"] = doc["attributes"]["uptime"];
                } else {
                  to_emit["uptime"] = "Undefined";
                }
                if (doc["attributes"]["platform"]) {
                  to_emit["platform"] = doc["attributes"]["platform"];
                } else {
                  to_emit["platform"] = "Undefined";
                }
                if (doc["attributes"]["platform_version"]) {
                  to_emit["platform_version"] = doc["attributes"]["platform_version"];
                } else {
                  to_emit["platform_version"] = "Undefined";
                }
                if (doc["run_list"]) {
                  to_emit["run_list"] = doc["run_list"];
                } else {
                  to_emit["run_list"] = "Undefined";
                }
                emit(doc.name, to_emit);
              }
            }
          EOJS
        },
        "by_run_list" => {
          "map" => <<-EOJS
            function(doc) {
              if (doc.chef_type == "node") {
                if (doc['run_list']) {
                  for (var i=0; i < doc.run_list.length; i++) {
                    emit(doc['run_list'][i], doc.name);
                  }
                }
              }
            }
          EOJS
        }
      },
    }

    # Create a new Chef::Node object.
    def initialize(couchdb=nil)
      @name = nil
      
      @normal_attrs = Mash.new
      @override_attrs = Mash.new
      @default_attrs = Mash.new
      @automatic_attrs = Mash.new
      @run_list = Chef::RunList.new

      @couchdb_rev = nil
      @couchdb_id = nil
      @couchdb = couchdb || Chef::CouchDB.new

      @run_state = {
        :template_cache => Hash.new,
        :seen_recipes => Hash.new,
        :seen_attributes => Hash.new
      }
      # TODO: 5/20/2010 need this here as long as other objects try to access
      # the cookbook collection via Node, otherwise get NoMethodError on nil.
      @cookbook_collection = CookbookCollection.new
    end

    def couchdb_id=(value)
      @couchdb_id = value
      @index_id = value
    end
    
    # Used by DSL
    def node
      self
    end

    def chef_server_rest
      Chef::REST.new(Chef::Config[:chef_server_url])
    end

    # Find a recipe for this Chef::Node by fqdn.  Will search first for 
    # Chef::Config["node_path"]/fqdn.rb, then hostname.rb, then default.rb.
    #
    # Returns a new Chef::Node object.
    #
    # Raises an ArgumentError if it cannot find the node.
    def find_file(fqdn)
      host_parts = fqdn.split(".")
      hostname = host_parts[0]

      [fqdn, hostname, "default"].each { |fname|
       node_file = File.join(Chef::Config[:node_path], "#{fname.to_s}.rb")
       return self.from_file(node_file) if File.exists?(node_file)
     }

      raise ArgumentError, "Cannot find a node matching #{fqdn}, not even with default.rb!"
    end

    # Set the name of this Node, or return the current name.
    def name(arg=nil)
      if arg != nil
        validate(
                 {:name => arg },
                 {:name => { :kind_of => String,
                     :cannot_be => :blank,
                     :regex => /^[\-[:alnum:]_:.]+$/}
                 })
        @name = arg
      else
        @name
      end
    end

    # Used by the DSL
    def attribute
      construct_attributes
    end
    
    def construct_attributes
      Chef::Node::Attribute.new(normal_attrs, default_attrs, override_attrs, automatic_attrs)
    end

    def attribute=(value)
      self.normal_attrs = value
    end
    
    # Return an attribute of this node.  Returns nil if the attribute is not found.
    def [](attrib)
      construct_attributes[attrib]
    end

    # Set an attribute of this node
    def []=(attrib, value)
      construct_attributes[attrib] = value
    end

    def store(attrib, value)
      self[attrib] = value
    end

    # Set a normal attribute of this node, but auto-vivifiy any Mashes that
    # might be missing
    def normal 
      attrs = construct_attributes
      attrs.set_type = :normal
      attrs.auto_vivifiy_on_read = true
      attrs
    end

    alias_method :set, :normal

    # Set a normal attribute of this node, auto-vivifiying any mashes that are
    # missing, but if the final value already exists, don't set it
    def normal_unless
      attrs = construct_attributes
      attrs.set_type = :normal
      attrs.auto_vivifiy_on_read = true
      attrs.set_unless_value_present = true
      attrs
    end
    alias_method :set_unless, :normal_unless
  
    # Set a default of this node, but auto-vivifiy any Mashes that might
    # be missing
    def default 
      attrs = construct_attributes
      attrs.set_type = :default
      attrs.auto_vivifiy_on_read = true
      attrs
    end

    # Set a default attribute of this node, auto-vivifiying any mashes that are
    # missing, but if the final value already exists, don't set it
    def default_unless
      attrs = construct_attributes
      attrs.set_type = :default
      attrs.auto_vivifiy_on_read = true
      attrs.set_unless_value_present = true
      attrs
    end

    # Set an override attribute of this node, but auto-vivifiy any Mashes that
    # might be missing
    def override 
      attrs = construct_attributes
      attrs.set_type = :override
      attrs.auto_vivifiy_on_read = true
      attrs
    end

    # Set an override attribute of this node, auto-vivifiying any mashes that
    # are missing, but if the final value already exists, don't set it
    def override_unless
      attrs = construct_attributes
      attrs.set_type = :override
      attrs.auto_vivifiy_on_read = true
      attrs.set_unless_value_present = true
      attrs
    end

    # Return true if this Node has a given attribute, false if not.  Takes either a symbol or
    # a string.
    #
    # Only works on the top level. Preferred way is to use the normal [] style
    # lookup and call attribute?()
    def attribute?(attrib)
      construct_attributes.attribute?(attrib)
    end

    # Yield each key of the top level to the block.
    def each(&block)
      construct_attributes.each(&block)
    end

    # Iterates over each attribute, passing the attribute and value to the block.
    def each_attribute(&block)
      construct_attributes.each_attribute(&block)
    end

    # Encouraged to only get used for lookups - while you can do sets from here, it's not as explicit
    # as using the normal/default/override interface.
    def method_missing(symbol, *args)
      attrs = construct_attributes
      attrs.send(symbol, *args)
    end

    # Returns true if this Node expects a given recipe, false if not.
    #
    # First, the run list is consulted to see whether the recipe is
    # explicitly included. If it's not there, it looks in
    # run_state[:seen_recipes], which is populated by include_recipe
    # statements in the DSL (and thus would not be in the run list).
    #
    # NOTE: We believe this is dead code, but if it's not, please
    # email chef-dev@opscode.com. [cw,timh]
#     def recipe?(recipe_name)
#       run_list.include?(recipe_name) || run_state[:seen_recipes].include?(recipe_name)
#     end
    
    # Returns true if this Node expects a given role, false if not.
    def role?(role_name)
      run_list.include?("role[#{role_name}]")
    end

    # Returns an Array of roles and recipes, in the order they will be applied.
    # If you call it with arguments, they will become the new list of roles and recipes.
    def run_list(*args)
      args.length > 0 ? @run_list.reset!(args) : @run_list
    end

    def recipes(*args)
      Chef::Log.warn "Chef::Node#recipes method is deprecated.  Please use Chef::Node#run_list"
      run_list(*args)
    end

    # Returns true if this Node expects a given role, false if not.
    def run_list?(item)
      run_list.detect { |r| r == item } ? true : false
    end

    # Consume data from ohai and Attributes provided as JSON on the command line.
    def consume_external_attrs(ohai_data, json_cli_attrs)
      Chef::Log.debug("Extracting run list from JSON attributes provided on command line")
      consume_attributes(json_cli_attrs)

      @automatic_attrs = ohai_data

      platform, version = Chef::Platform.find_platform_and_version(self)
      Chef::Log.debug("Platform is #{platform} version #{version}")
      @automatic_attrs[:platform] = platform
      @automatic_attrs[:platform_version] = version
    end

    # Consumes the combined run_list and other attributes in +attrs+
    def consume_attributes(attrs)
      normal_attrs_to_merge = consume_run_list(attrs)
      Chef::Log.debug("Applying attributes from json file")
      @normal_attrs = Chef::Mixin::DeepMerge.merge(@normal_attrs,normal_attrs_to_merge)
      self[:tags] = Array.new unless attribute?(:tags)
    end

    # Extracts the run list from +attrs+ and applies it. Returns the remaining attributes
    def consume_run_list(attrs)
      attrs = attrs ? attrs.dup : {}
      if new_run_list = attrs.delete("recipes") || attrs.delete("run_list")
        if attrs.key?("recipes") || attrs.key?("run_list")
          raise Chef::Exceptions::AmbiguousRunlistSpecification, "please set the node's run list using the 'run_list' attribute only."
        end
        Chef::Log.info("Setting the run_list to #{new_run_list.inspect} from JSON")
        run_list(new_run_list)
      end
      attrs
    end

    # Clear defaults and overrides, so that any deleted attributes between runs are
    # still gone.
    def reset_defaults_and_overrides
      @default_attrs = Mash.new
      @override_attrs = Mash.new
    end

    # Expands the node's run list and deep merges the default and
    # override attributes. Also applies stored attributes (from json provided
    # on the command line)
    #
    # Returns the fully-expanded list of recipes.
    #
    # TODO: timh/cw, 5-14-2010: Should this method exist? Should we
    # instead modify default_attrs and override_attrs whenever our
    # run_list is mutated? Or perhaps do something smarter like
    # on-demand generation of default_attrs and override_attrs,
    # invalidated only when run_list is mutated?
    def expand!
      # This call should only be called on a chef-client run.
      expansion = run_list.expand('server')
      raise Chef::Exceptions::MissingRole if expansion.errors?

      self[:tags] = Array.new unless attribute?(:tags)
      @default_attrs = Chef::Mixin::DeepMerge.merge(default_attrs, expansion.default_attrs)
      @override_attrs = Chef::Mixin::DeepMerge.merge(override_attrs, expansion.override_attrs)

      @automatic_attrs[:recipes] = expansion.recipes
      @automatic_attrs[:roles] = expansion.roles

      expansion.recipes
    end

    # Transform the node to a Hash
    def to_hash
      index_hash = Hash.new
      index_hash["chef_type"] = "node"
      index_hash["name"] = name
      attribute.each do |key, value|
        index_hash[key] = value
      end
      index_hash["recipe"] = run_list.recipe_names if run_list.recipe_names.length > 0
      index_hash["role"] = run_list.role_names if run_list.role_names.length > 0
      index_hash["run_list"] = run_list.run_list if run_list.run_list.length > 0
      index_hash
    end

    # Serialize this object as a hash
    def to_json(*a)
      result = {
        "name" => name,
        'json_class' => self.class.name,
        "automatic" => automatic_attrs,
        "normal" => normal_attrs,
        "chef_type" => "node",
        "default" => default_attrs,
        "override" => override_attrs,
        "run_list" => run_list.run_list
      }
      result["_rev"] = couchdb_rev if couchdb_rev
      result.to_json(*a)
    end

    # Create a Chef::Node from JSON
    def self.json_create(o)
      node = new
      node.name(o["name"])

      if o.has_key?("attributes")
        node.normal_attrs = o["attributes"]
      end
      node.automatic_attrs = Mash.new(o["automatic"]) if o.has_key?("automatic")
      node.normal_attrs = Mash.new(o["normal"]) if o.has_key?("normal")
      node.default_attrs = Mash.new(o["default"]) if o.has_key?("default")
      node.override_attrs = Mash.new(o["override"]) if o.has_key?("override")

      if o.has_key?("run_list")
        node.run_list.reset!(o["run_list"])
      else
        o["recipes"].each { |r| node.recipes << r }
      end
      node.couchdb_rev = o["_rev"] if o.has_key?("_rev")
      node.couchdb_id = o["_id"] if o.has_key?("_id")
      node.index_id = node.couchdb_id
      node
    end

    # List all the Chef::Node objects in the CouchDB.  If inflate is set to true, you will get
    # the full list of all Nodes, fully inflated.
    def self.cdb_list(inflate=false, couchdb=nil)
      rs =(couchdb || Chef::CouchDB.new).list("nodes", inflate)
      lookup = (inflate ? "value" : "key")
      rs["rows"].collect { |r| r[lookup] }
    end

    def self.list(inflate=false)
      if inflate
        response = Hash.new
        Chef::Search::Query.new.search(:node) do |n|
          response[n.name] = n unless n.nil?
        end
        response
      else
        Chef::REST.new(Chef::Config[:chef_server_url]).get_rest("nodes")
      end
    end

    # Load a node by name from CouchDB
    def self.cdb_load(name, couchdb=nil)
      (couchdb || Chef::CouchDB.new).load("node", name)
    end

    def self.exists?(nodename, couchdb)
      begin
        self.cdb_load(nodename, couchdb)
      rescue Chef::Exceptions::CouchDBNotFound
        nil
      end
    end

    def self.find_or_create(node_name)
      load(node_name)
    rescue Net::HTTPServerException => e
      raise unless e.response.code == '404'
      node = build(node_name)
      node.create
    end

    def self.build(node_name)
      node = new
      node.name(node_name)
      node
    end

    # Load a node by name
    def self.load(name)
      Chef::REST.new(Chef::Config[:chef_server_url]).get_rest("nodes/#{name}")
    end

    # Remove this node from the CouchDB
    def cdb_destroy
      couchdb.delete("node", name, couchdb_rev)
    end

    # Remove this node via the REST API
    def destroy
      chef_server_rest.delete_rest("nodes/#{name}")
    end

    # Save this node to the CouchDB
    def cdb_save
      @couchdb_rev = couchdb.store("node", name, self)["rev"]
    end

    # Save this node via the REST API
    def save
      # Try PUT. If the node doesn't yet exist, PUT will return 404,
      # so then POST to create.
      begin
        chef_server_rest.put_rest("nodes/#{name}", self)
      rescue Net::HTTPServerException => e
        raise e unless e.response.code == "404"
        chef_server_rest.post_rest("nodes", self)
      end
      self
    end

    # Create the node via the REST API
    def create
      chef_server_rest.post_rest("nodes", self)
      self
    end

    # Set up our CouchDB design document
    def self.create_design_document(couchdb=nil)
      (couchdb || Chef::CouchDB.new).create_design_document("nodes", DESIGN_DOCUMENT)
    end
    
    def to_s
      "node[#{name}]"
    end
    
    # Load all attribute files for all cookbooks associated with this
    # node.
    def load_attributes
      cookbook_collection.values.each do |cookbook|
        cookbook.segment_filenames(:attributes).each do |segment_filename|
          Chef::Log.debug("node #{name} loading cookbook #{cookbook.name}'s attribute file #{segment_filename}")
          self.from_file(segment_filename)
        end
      end
    end
    
    # Used by DSL.
    # Loads the attribute file specified by the short name of the
    # file, e.g., loads specified cookbook's
    #   "attributes/mailservers.rb"
    # if passed
    #   "mailservers"
    def load_attribute_by_short_filename(name, src_cookbook_name)
      src_cookbook = cookbook_collection[src_cookbook_name]
      raise Chef::Exceptions::CookbookNotFound, "could not find cookbook #{src_cookbook_name} while loading attribute #{name}" unless src_cookbook
      
      attribute_filename = src_cookbook.attribute_filenames_by_short_filename[name]
      raise Chef::Exceptions::AttributeNotFound, "could not find filename for attribute #{name} in cookbook #{src_cookbook_name}" unless attribute_filename

      self.from_file(attribute_filename)
      self
    end

  end
end
