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
  # == Chef::Checksum
  # Checksum for an individual file; e.g., used for sandbox/cookbook uploading
  # to track which files the system already manages.
  class Checksum
    attr_accessor :checksum, :create_time
    attr_accessor :couchdb_id, :couchdb_rev

    # When a Checksum commits a sandboxed file to its final home in the checksum
    # repo, this attribute will have the original on-disk path where the file
    # was stored; it will be used if the commit is reverted to restore the sandbox
    # to the pre-commit state.
    attr_reader :original_committed_file_location

    DESIGN_DOCUMENT = {
      "version" => 1,
      "language" => "javascript",
      "views" => {
        "all" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "checksum") {
              emit(doc.checksum, doc);
            }
          }
          EOJS
        },
      }
    }
    
    # Creates a new Chef::Checksum object.
    # === Arguments
    # checksum::: the MD5 content hash of the file
    # couchdb::: An instance of Chef::CouchDB
    #
    # === Returns
    # object<Chef::Checksum>:: Duh. :)
    def initialize(checksum=nil, couchdb=nil)
      @create_time = Time.now.iso8601
      @checksum = checksum
      @original_committed_file_location = nil
    end
    
    def to_json(*a)
      result = {
        :checksum => checksum,
        :create_time => create_time,
        :json_class => self.class.name,
        :chef_type => 'checksum',

        # For Chef::CouchDB (id_to_name, name_to_id)
        :name => checksum
      }
      result.to_json(*a)
    end

    def self.json_create(o)
      checksum = new(o['checksum'])
      checksum.create_time = o['create_time']

      if o.has_key?('_rev')
        checksum.couchdb_rev = o["_rev"]
        o.delete("_rev")
      end
      if o.has_key?("_id")
        checksum.couchdb_id = o["_id"]
        o.delete("_id")
      end
      checksum
    end


    ##
    # On-Disk Checksum File Repo (Chef Server API)
    ##

    def file_location
      File.join(checksum_repo_directory, checksum)
    end

    def checksum_repo_directory
      File.join(Chef::Config.checksum_path, checksum[0..1])
    end

    # Moves the given +sandbox_file+ into the checksum repo using the path
    # given by +file_location+ and saves the Checksum to the database
    def commit_sandbox_file(sandbox_file)
      @original_committed_file_location = sandbox_file
      Chef::Log.info("commiting sandbox file: move #{sandbox_file} to #{file_location}")
      FileUtils.mkdir_p(checksum_repo_directory)
      File.rename(sandbox_file, file_location)
      cdb_save
    end

    # Moves the checksum file back to its pre-commit location and deletes
    # the checksum object from the database, effectively undoing +commit_sandbox_file+.
    # Raises Chef::Exceptions::IllegalChecksumRevert if the original file location
    # is unknown, which is will be the case if commit_sandbox_file was not
    # previously called
    def revert_sandbox_file_commit
      unless original_committed_file_location
        raise Chef::Exceptions::IllegalChecksumRevert, "Checksum #{self.inspect} cannot be reverted because the original sandbox file location is not known"
      end

      Chef::Log.warn("reverting sandbox file commit: moving #{file_location} back to #{original_committed_file_location}")
      File.rename(file_location, original_committed_file_location)
      cdb_destroy
    end

    # Removes the on-disk file backing this checksum object, then removes it
    # from the database
    def purge
      purge_file
      cdb_destroy
    end

    ##
    # Couchdb
    ##

    def self.create_design_document(couchdb=nil)
      (couchdb || Chef::CouchDB.new).create_design_document("checksums", DESIGN_DOCUMENT)
    end
    
    def self.cdb_list(inflate=false, couchdb=nil)
      rs = (couchdb || Chef::CouchDB.new).list("checksums", inflate)
      lookup = (inflate ? "value" : "key")
      rs["rows"].collect { |r| r[lookup] }        
    end
    
    def self.cdb_all_checksums(couchdb = nil)
      rs = (couchdb || Chef::CouchDB.new).list("checksums", true)
      rs["rows"].inject({}) { |hash_result, r| hash_result[r['key']] = 1; hash_result }
    end

    def self.cdb_load(checksum, couchdb=nil)
      # Probably want to look for a view here at some point
      (couchdb || Chef::CouchDB.new).load("checksum", checksum)
    end

    def cdb_destroy(couchdb=nil)
      (couchdb || Chef::CouchDB.new).delete("checksum", checksum, @couchdb_rev)
    end

    def cdb_save(couchdb=nil)
      @couchdb_rev = (couchdb || Chef::CouchDB.new).store("checksum", checksum, self)["rev"]
    end


    private

    # Deletes the file backing this checksum from the on-disk repo.
    # Purging the checksums is how users can get back to a valid state if
    # they've deleted files, so we silently swallow Errno::ENOENT here.
    def purge_file
      FileUtils.rm(file_location)
    rescue Errno::ENOENT
      true
    end

  end
end
