#
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

require 'chef/log'
require 'uuidtools'

class Chef
  class Sandbox
    attr_accessor :is_completed, :create_time
    alias_method :is_completed?, :is_completed
    attr_reader :guid
    
    alias :name :guid
    
    attr_accessor :couchdb, :couchdb_id, :couchdb_rev

    # list of checksum ids
    attr_accessor :checksums

    DESIGN_DOCUMENT = {
      "version" => 1,
      "language" => "javascript",
      "views" => {
        "all" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "sandbox") {
              emit(doc.guid, doc);
            }
          }
          EOJS
        },
        "all_id" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "sandbox") {
              emit(doc.guid, doc.guid);
            }
          }
          EOJS
        },
        "all_incomplete" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "sandbox" && !doc.is_completed) {
              emit(doc.guid, doc.guid);
            }
          }
          EOJS
        },
        "all_completed" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "sandbox" && doc.is_completed) {
              emit(doc.guid, doc.guid);
            }
          }
          EOJS
        },
      }
    }
    
    # Creates a new Chef::Sandbox object.  
    #
    # === Returns
    # object<Chef::Sandbox>:: Duh. :)
    def initialize(guid=nil, couchdb=nil)
      @guid = guid || UUIDTools::UUID.random_create.to_s.gsub(/\-/,'').downcase
      @is_completed = false
      @create_time = Time.now.iso8601
      @checksums = Array.new
    end

    def include?(checksum)
      @checksums.include?(checksum)
    end

    alias :member? :include?

    def to_json(*a)
      result = {
        :guid => guid,
        :name => name,   # same as guid, used for id_map
        :checksums => checksums,
        :create_time => create_time,
        :is_completed => is_completed,
        :json_class => self.class.name,
        :chef_type => 'sandbox'
      }
      result["_rev"] = @couchdb_rev if @couchdb_rev
      result.to_json(*a)
    end

    def self.json_create(o)
      sandbox = new(o['guid'])
      sandbox.checksums = o['checksums']
      sandbox.create_time = o['create_time']
      sandbox.is_completed = o['is_completed']
      if o.has_key?('_rev')
        sandbox.couchdb_rev = o["_rev"]
        o.delete("_rev")
      end
      if o.has_key?("_id")
        sandbox.couchdb_id = o["_id"]
        #sandbox.index_id = sandbox.couchdb_id
        o.delete("_id")
      end
      sandbox
    end

    ##
    # Couchdb
    ##
    
    def self.create_design_document(couchdb=nil)
      (couchdb || Chef::CouchDB.new).create_design_document("sandboxes", DESIGN_DOCUMENT)
    end
    
    def self.cdb_list(inflate=false, couchdb=nil)
      rs = (couchdb || Chef::CouchDB.new).list("sandboxes", inflate)
      lookup = (inflate ? "value" : "key")
      rs["rows"].collect { |r| r[lookup] }            
    end

    def self.cdb_load(guid, couchdb=nil)
      # Probably want to look for a view here at some point
      (couchdb || Chef::CouchDB.new).load("sandbox", guid)
    end

    def cdb_destroy
      (couchdb || Chef::CouchDB.new).delete("sandbox", guid, @couchdb_rev)
    end

    def cdb_save(couchdb=nil)
      @couchdb_rev = (couchdb || Chef::CouchDB.new).store("sandbox", guid, self)["rev"]
    end

  end
end
