#
# Author:: Adam Jacob (<adam@opscode.com>)
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

require 'chef/mixin/params_validate'
require 'chef/config'
require 'chef/rest'
require 'chef/log'
require 'digest/sha2'
require 'json'

# We want to fail on create if uuidtools isn't installed
begin
  require 'uuidtools'
rescue LoadError
end

class Chef
  class CouchDB
    include Chef::Mixin::ParamsValidate

    def initialize(url=nil, db=Chef::Config[:couchdb_database])
      url ||= Chef::Config[:couchdb_url]
      @db = db
      @rest = Chef::REST.new(url, nil, nil)
    end

    def couchdb_database(args=nil)
      @db = args || @db
    end

    def create_id_map
      create_design_document(
        "id_map", 
        {
          "version" => 1,
          "language" => "javascript",
          "views" => {
            "name_to_id" => {
              "map" => <<-EOJS
                function(doc) {
                  emit([ doc.chef_type, doc.name], doc._id);
                }
              EOJS
            },
            "id_to_name" => {
              "map" => <<-EOJS
                function(doc) { 
                  emit(doc._id, [ doc.chef_type, doc.name ]);
                }
              EOJS
            }
          }
        }
      )
    end

    def create_db
      @database_list = @rest.get_rest("_all_dbs")
      unless @database_list.detect { |db| db == couchdb_database }
        response = @rest.put_rest(couchdb_database, Hash.new)
      end
      couchdb_database
    end
    
    def create_design_document(name, data)
      create_db
      to_update = true
      begin
        old_doc = @rest.get_rest("#{couchdb_database}/_design/#{name}")
        if data["version"] != old_doc["version"]
          data["_rev"] = old_doc["_rev"]
          Chef::Log.debug("Updating #{name} views")
        else
          to_update = false
        end
      rescue 
        Chef::Log.debug("Creating #{name} views for the first time because: #{$!}")
      end
      if to_update
        @rest.put_rest("#{couchdb_database}/_design%2F#{name}", data)
      end
      true
    end

    # Save the object to Couch. Add to index if the object supports it.
    def store(obj_type, name, object)
      validate(
        {
          :obj_type => obj_type,
          :name => name,
          :object => object,
        },
        {
          :object => { :respond_to => :to_json },
        }
      )
      rows = get_view("id_map", "name_to_id", :key => [ obj_type, name ])["rows"]
      uuid = rows.empty? ? UUIDTools::UUID.random_create.to_s : rows.first.fetch("id")
     
      db_put_response = @rest.put_rest("#{couchdb_database}/#{uuid}", object)

      if object.respond_to?(:add_to_index)
        Chef::Log.info("Sending #{obj_type}(#{uuid}) to the index queue for addition.")
        object.add_to_index(:database => couchdb_database, :id => uuid, :type => obj_type)
      end
      
      db_put_response
    end

    def load(obj_type, name)
      validate(
        {
          :obj_type => obj_type,
          :name => name,
        },
        {
          :obj_type => { :kind_of => String },
          :name => { :kind_of => String },
        }
               )
      doc = find_by_name(obj_type, name)
      doc.couchdb = self if doc.respond_to?(:couchdb)
      doc 
    end
  
    def delete(obj_type, name, rev=nil)
      validate(
        {
          :obj_type => obj_type,
          :name => name,
        },
        {
          :obj_type => { :kind_of => String },
          :name => { :kind_of => String },
        }
      )
      del_id = nil 
      object, uuid = find_by_name(obj_type, name, true)
      unless rev
        if object.respond_to?(:couchdb_rev)
          rev = object.couchdb_rev
        else
          rev = object['_rev']
        end
      end
      response = @rest.delete_rest("#{couchdb_database}/#{uuid}?rev=#{rev}")
      response.couchdb = self if response.respond_to?(:couchdb=)
      
      if object.respond_to?(:delete_from_index)
        Chef::Log.info("Sending #{obj_type}(#{uuid}) to the index queue for deletion..")
        object.delete_from_index(:database => couchdb_database, :id => uuid, :type => obj_type)
      end

      response
    end
  
    def list(view, inflate=false)
      validate(
        { 
          :view => view,
        },
        {
          :view => { :kind_of => String }
        }
      )
      if inflate
        r = @rest.get_rest(view_uri(view, "all"))
        r["rows"].each { |i| i["value"].couchdb = self if i["value"].respond_to?(:couchdb=) }
        r
      else
        r = @rest.get_rest(view_uri(view, "all_id"))
      end
      r
    end
  
    def has_key?(obj_type, name)
      validate(
        {
          :obj_type => obj_type,
          :name => name,
        },
        {
          :obj_type => { :kind_of => String },
          :name => { :kind_of => String },
        }
      )
      begin
        find_by_name(obj_type, name)
        true
      rescue
        false
      end
    end

    def find_by_name(obj_type, name, with_id=false)
      r = get_view("id_map", "name_to_id", :key => [ obj_type, name ], :include_docs => true)
      if r["rows"].length == 0
        raise Chef::Exceptions::CouchDBNotFound, "Cannot find #{obj_type} #{name} in CouchDB!"
      end
      if with_id
        [ r["rows"][0]["doc"], r["rows"][0]["id"] ]
      else
        r["rows"][0]["doc"] 
      end
    end

    def get_view(design, view, options={})
      view_string = view_uri(design, view)
      view_string << "?" if options.length != 0
      view_string << options.map { |k,v| "#{k}=#{URI.escape(v.to_json)}"}.join('&')
      @rest.get_rest(view_string)
    end

    def bulk_get(*to_fetch)
      response = @rest.post_rest("#{couchdb_database}/_all_docs?include_docs=true", { "keys" => to_fetch.flatten })
      response["rows"].collect { |r| r["doc"] }
    end
    
    def view_uri(design, view)
      "#{couchdb_database}/_design/#{design}/_view/#{view}"
    end
    
  end
end
