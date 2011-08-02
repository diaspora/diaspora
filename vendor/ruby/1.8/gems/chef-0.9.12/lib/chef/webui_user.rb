#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
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
#

require 'chef/config'
require 'chef/mixin/params_validate'
require 'chef/couchdb'
require 'chef/index_queue'
require 'digest/sha1'
require 'json'
  

class Chef
  class WebUIUser
    
    attr_accessor :name, :validated, :admin, :openid, :couchdb
    attr_reader   :password, :salt, :couchdb_id, :couchdb_rev
    
    include Chef::Mixin::ParamsValidate
    
    DESIGN_DOCUMENT = {
      "version" => 3,
      "language" => "javascript",
      "views" => {
        "all" => {
          "map" => <<-EOJS
            function(doc) {
              if (doc.chef_type == "webui_user") {
                emit(doc.name, doc);
              }
            }
          EOJS
        },
        "all_id" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "webui_user") {
              emit(doc.name, doc.name);
            }
          }
          EOJS
        },
      },
    }
    
    # Create a new Chef::WebUIUser object.
    def initialize(opts={})
      @name, @salt, @password = opts['name'], opts['salt'], opts['password']
      @openid, @couchdb_rev, @couchdb_id = opts['openid'], opts['_rev'], opts['_id']
      @admin = false
      @couchdb = Chef::CouchDB.new
    end
    
    def name=(n)
      @name = n.gsub(/\./, '_')
    end
    
    def admin?
      admin
    end
    
    # Set the password for this object.
    def set_password(password, confirm_password=password) 
      raise ArgumentError, "Passwords do not match" unless password == confirm_password
      raise ArgumentError, "Password cannot be blank" if (password.nil? || password.length==0)
      raise ArgumentError, "Password must be a minimum of 6 characters" if password.length < 6
      generate_salt
      @password = encrypt_password(password)      
    end
    
    def set_openid(given_openid)
      @openid = given_openid
    end 
    
    def verify_password(given_password)
      encrypt_password(given_password) == @password
    end 
    
    # Serialize this object as a hash 
    def to_json(*a)
      attributes = Hash.new
      recipes = Array.new
      result = {
        'name' => name,
        'json_class' => self.class.name,
        'salt' => salt,
        'password' => password,
        'openid' => openid,
        'admin' => admin,
        'chef_type' => 'webui_user',
      }
      result["_id"]  = @couchdb_id if @couchdb_id  
      result["_rev"] = @couchdb_rev if @couchdb_rev
      result.to_json(*a)
    end
    
    # Create a Chef::WebUIUser from JSON
    def self.json_create(o)
      me = new(o)
      me.admin = o["admin"]
      me
    end
    
    # List all the Chef::WebUIUser objects in the CouchDB.  If inflate is set to true, you will get
    # the full list of all registration objects.  Otherwise, you'll just get the IDs
    def self.cdb_list(inflate=false)
      rs = Chef::CouchDB.new.list("users", inflate)
      if inflate
        rs["rows"].collect { |r| r["value"] }
      else
        rs["rows"].collect { |r| r["key"] }
      end
    end
    
    def self.list(inflate=false)
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      if inflate
        response = Hash.new
        Chef::Search::Query.new.search(:user) do |n|
          response[n.name] = n unless n.nil?
        end
        response
      else
        r.get_rest("users")
      end
    end
    
    # Load an WebUIUser by name from CouchDB
    def self.cdb_load(name)
      Chef::CouchDB.new.load("webui_user", name)
    end
    
    # Load a User by name
    def self.load(name)
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      r.get_rest("users/#{name}")
    end
    
    
    # Whether or not there is an WebUIUser with this key.
    def self.has_key?(name)
      Chef::CouchDB.new.has_key?("webui_user", name)
    end
    
    # Remove this WebUIUser from the CouchDB
    def cdb_destroy
      couchdb.delete("webui_user", @name, @couchdb_rev)
    end
    
    # Remove this WebUIUser via the REST API
    def destroy
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      r.delete_rest("users/#{@name}")
    end
    
    # Save this WebUIUser to the CouchDB
    def cdb_save
      results = couchdb.store("webui_user", @name, self)
      @couchdb_rev = results["rev"]
    end
    
    # Save this WebUIUser via the REST API
    def save
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      begin
        r.put_rest("users/#{@name}", self)
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          r.post_rest("users", self)
        else
          raise e
        end
      end
      self
    end
    
    # Create the WebUIUser via the REST API
    def create
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      r.post_rest("users", self)
      self
    end
    
    # Set up our CouchDB design document
    def self.create_design_document(couchdb=nil)
      couchdb ||= Chef::CouchDB.new
      couchdb.create_design_document("users", DESIGN_DOCUMENT)
    end
    
    #return true if an admin user exists. this is pretty expensive (O(n)), should think of a better way (nuo)
    def self.admin_exist
      users = self.cdb_list
      users.each do |u|
        user = self.cdb_load(u)
        if user.admin
          return user.name
        end
      end
      nil
    end
    
    protected
    
      def generate_salt
        @salt = Time.now.to_s
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        1.upto(30) { |i| @salt << chars[rand(chars.size-1)] }
        @salt
      end
    
      def encrypt_password(password)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      end
    
  end
end
