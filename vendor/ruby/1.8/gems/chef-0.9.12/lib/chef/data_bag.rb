#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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
require 'chef/mixin/params_validate'
require 'chef/mixin/from_file'
require 'chef/couchdb'
require 'chef/data_bag_item'
require 'chef/index_queue'
require 'extlib'
require 'json'

class Chef
  class DataBag 
    
    include Chef::Mixin::FromFile
    include Chef::Mixin::ParamsValidate
    include Chef::IndexQueue::Indexable
    
    DESIGN_DOCUMENT = {
      "version" => 2,
      "language" => "javascript",
      "views" => {
        "all" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "data_bag") {
              emit(doc.name, doc);
            }
          }
          EOJS
        },
        "all_id" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "data_bag") {
              emit(doc.name, doc.name);
            }
          }
          EOJS
        },
        "entries" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "data_bag_item") {
              emit(doc.data_bag, doc.raw_data.id);
            }
          }
          EOJS
        }
      }
    }

    attr_accessor :couchdb_rev, :couchdb_id, :couchdb
    
    # Create a new Chef::DataBag
    def initialize(couchdb=nil)
      @name = '' 
      @couchdb_rev = nil
      @couchdb_id = nil
      @couchdb = (couchdb || Chef::CouchDB.new)
    end

    def name(arg=nil) 
      set_or_return(
        :name,
        arg,
        :regex => /^[\-[:alnum:]_]+$/
      )
    end

    def to_hash
      result = {
        "name" => @name,
        'json_class' => self.class.name,
        "chef_type" => "data_bag",
      }
      result["_rev"] = @couchdb_rev if @couchdb_rev
      result
    end

    # Serialize this object as a hash 
    def to_json(*a)
      to_hash.to_json(*a)
    end

    def chef_server_rest
      Chef::REST.new(Chef::Config[:chef_server_url])
    end

    def self.chef_server_rest
      Chef::REST.new(Chef::Config[:chef_server_url])
    end
    
    # Create a Chef::Role from JSON
    def self.json_create(o)
      bag = new
      bag.name(o["name"])
      bag.couchdb_rev = o["_rev"] if o.has_key?("_rev")
      bag.couchdb_id = o["_id"] if o.has_key?("_id")
      bag.index_id = bag.couchdb_id
      bag
    end
    
    # List all the Chef::DataBag objects in the CouchDB.  If inflate is set to true, you will get
    # the full list of all Roles, fully inflated.
    def self.cdb_list(inflate=false, couchdb=nil)
      rs = (couchdb || Chef::CouchDB.new).list("data_bags", inflate)
      lookup = (inflate ? "value" : "key")
      rs["rows"].collect { |r| r[lookup] }
    end
    
    def self.list(inflate=false)
      if inflate
        # Can't search for all data bags like other objects, fall back to N+1 :(
        list(false).inject({}) do |response, bag_and_uri|
          response[bag_and_uri.first] = load(bag_and_uri.first)
          response
        end
      else
        Chef::REST.new(Chef::Config[:chef_server_url]).get_rest("data")
      end
    end
    
    # Load a Data Bag by name from CouchDB
    def self.cdb_load(name, couchdb=nil)
      (couchdb || Chef::CouchDB.new).load("data_bag", name)
    end
    
    # Load a Data Bag by name via the RESTful API
    def self.load(name)
      Chef::REST.new(Chef::Config[:chef_server_url]).get_rest("data/#{name}")
    end
    
    # Remove this Data Bag from CouchDB
    def cdb_destroy
      removed = @couchdb.delete("data_bag", @name, @couchdb_rev)
      rs = @couchdb.get_view("data_bags", "entries", :include_docs => true, :startkey => @name, :endkey => @name)
      rs["rows"].each do |row|
        row["doc"].couchdb = couchdb
        row["doc"].cdb_destroy
      end
      removed
    end
    
    def destroy
      chef_server_rest.delete_rest("data/#{@name}")
    end
    
    # Save this Data Bag to the CouchDB
    def cdb_save
      results = @couchdb.store("data_bag", @name, self)
      @couchdb_rev = results["rev"]
    end
    
    # Save the Data Bag via RESTful API
    def save
      begin
        chef_server_rest.put_rest("data/#{@name}", self)
      rescue Net::HTTPServerException => e
        raise e unless e.response.code == "404"
        chef_server_rest.post_rest("data", self)
      end
      self
    end
    
    #create a data bag via RESTful API
    def create
      chef_server_rest.post_rest("data", self)
      self
    end

    # List all the items in this Bag from CouchDB
    # The self.load method does this through the REST API
    def list(inflate=false)
      rs = nil 
      if inflate
        rs = @couchdb.get_view("data_bags", "entries", :include_docs => true, :startkey => @name, :endkey => @name)
        rs["rows"].collect { |r| r["doc"] }
      else
        rs = @couchdb.get_view("data_bags", "entries", :startkey => @name, :endkey => @name)
        rs["rows"].collect { |r| r["value"] }
      end
    end
    
    # Set up our CouchDB design document
    def self.create_design_document(couchdb=nil)
      (couchdb || Chef::CouchDB.new).create_design_document("data_bags", DESIGN_DOCUMENT)
    end
    
    # As a string
    def to_s
      "data_bag[#{@name}]"
    end

  end
end

