#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
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

require 'chef/log'
require 'chef/client'
require 'chef/node'
require 'chef/resource_definition_list'
require 'chef/recipe'
require 'chef/cookbook/file_vendor'

class Chef
  # == Chef::CookbookVersion
  # CookbookVersion is a model object encapsulating the data about a Chef
  # cookbook. Chef supports maintaining multiple versions of a cookbook on a
  # single server; each version is represented by a distinct instance of this
  # class.
  #--
  # TODO: timh/cw: 5-24-2010: mutators for files (e.g., recipe_filenames=,
  # recipe_filenames.insert) should dirty the manifest so it gets regenerated.
  class CookbookVersion
    include Chef::IndexQueue::Indexable

    COOKBOOK_SEGMENTS = [ :resources, :providers, :recipes, :definitions, :libraries, :attributes, :files, :templates, :root_files ]
    
    DESIGN_DOCUMENT = {
      "version" => 7,
      "language" => "javascript",
      "views" => {
        "all" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "cookbook_version") {
              emit(doc.name, doc);
            }
          }
          EOJS
        },
        "all_id" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "cookbook_version") {
              emit(doc.name, doc.name);
            }
          }
          EOJS
        },
        "all_with_version" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "cookbook_version") {
              emit(doc.cookbook_name, doc.version);
            }
          }
          EOJS
        },
        "all_latest_version" => {
          "map" => %q@
          function(doc) { 
            if (doc.chef_type == "cookbook_version") {
              emit(doc.cookbook_name, doc.version);
            }
          }
          @,
          "reduce" => %q@
          function(keys, values, rereduce) {
            var result = null;

            for (var idx in values) {
              var value = values[idx];
              
              if (idx == 0) {
                result = value;
                continue;
              }
              
              var valueParts = value.split('.').map(function(v) { return parseInt(v); });
              var resultParts = result.split('.').map(function(v) { return parseInt(v); });

              if (valueParts[0] != resultParts[0]) {
                if (valueParts[0] > resultParts[0]) {
                  result = value;
                }
              }
              else if (valueParts[1] != resultParts[1]) {
                if (valueParts[1] > resultParts[1]) {
                  result = value;
                }
              }
              else if (valueParts[2] != resultParts[2]) {
                if (valueParts[2] > resultParts[2]) {
                  result = value;
                }
              }
            }
            return result;
          }
          @
        },
        "all_latest_version_by_id" => {
          "map" => %q@
          function(doc) {
            if (doc.chef_type == "cookbook_version") {
              emit(doc.cookbook_name, {version: doc.version, id:doc._id});
            }
          }
          @,
          "reduce" => %q@
          function(keys, values, rereduce) {
            var result = null;

            for (var idx in values) {
              var value = values[idx];

              if (idx == 0) {
                result = value;
                continue;
              }

              var valueParts = value.version.split('.').map(function(v) { return parseInt(v); });
              var resultParts = result.version.split('.').map(function(v) { return parseInt(v); });

              if (valueParts[0] != resultParts[0]) {
                if (valueParts[0] > resultParts[0]) {
                  result = value;
                }
              }
              else if (valueParts[1] != resultParts[1]) {
                if (valueParts[1] > resultParts[1]) {
                  result = value;
                }
              }
              else if (valueParts[2] != resultParts[2]) {
                if (valueParts[2] > resultParts[2]) {
                  result = value;
                }
              }
            }
            return result;
          }
          @
        },
      }
    }

    attr_accessor :root_dir
    attr_accessor :definition_filenames
    attr_accessor :template_filenames
    attr_accessor :file_filenames
    attr_accessor :library_filenames
    attr_accessor :resource_filenames
    attr_accessor :provider_filenames
    attr_accessor :root_filenames
    attr_accessor :name
    attr_accessor :metadata
    attr_accessor :metadata_filenames
    attr_accessor :status
    attr_accessor :couchdb_rev
    attr_accessor :couchdb

    attr_reader :couchdb_id

    # attribute_filenames also has a setter that has non-default
    # functionality.
    attr_reader :attribute_filenames

    # recipe_filenames also has a setter that has non-default
    # functionality.
    attr_reader :recipe_filenames

    attr_reader :recipe_filenames_by_name
    attr_reader :attribute_filenames_by_short_filename
    
    # This is the one and only method that knows how cookbook files'
    # checksums are generated.
    def self.checksum_cookbook_file(filepath)
      Chef::ChecksumCache.generate_md5_checksum_for_file(filepath)
    rescue Errno::ENOENT
      Chef::Log.debug("File #{filepath} does not exist, so there is no checksum to generate")
      nil
    end
    
    # Keep track of the filenames that we use in both eager cookbook
    # downloading (during sync_cookbooks) and lazy (during the run
    # itself, through FileVendor). After the run is over, clean up the
    # cache.
    def self.valid_cache_entries
      @valid_cache_entries ||= {}
    end

    def self.reset_cache_validity
      @valid_cache_entries = nil
    end

    def self.cache
      Chef::FileCache
    end

    # Setup a notification to clear the valid_cache_entries when a Chef client
    # run starts
    Chef::Client.when_run_starts do |run_status|
      reset_cache_validity
    end

    # Synchronizes all the cookbooks from the chef-server.
    #
    # === Returns
    # true:: Always returns true
    def self.sync_cookbooks(cookbook_hash)
      Chef::Log.debug("Cookbooks to load: #{cookbook_hash.inspect}")

      clear_obsoleted_cookbooks(cookbook_hash)

      # Synchronize each of the node's cookbooks, and add to the
      # valid_cache_entries hash.
      cookbook_hash.values.each do |cookbook|
        sync_cookbook_file_cache(cookbook)
      end

      true
    end

    # Iterates over cached cookbooks' files, removing files belonging to
    # cookbooks that don't appear in +cookbook_hash+
    def self.clear_obsoleted_cookbooks(cookbook_hash)
      # Remove all cookbooks no longer relevant to this node
      cache.find(File.join(%w{cookbooks ** *})).each do |cache_file|
        cache_file =~ /^cookbooks\/([^\/]+)\//
        unless cookbook_hash.has_key?($1)
          Chef::Log.info("Removing #{cache_file} from the cache; its cookbook is no longer needed on this client.")
          cache.delete(cache_file)
        end
      end
    end

    # Update the file caches for a given cache segment.  Takes a segment name
    # and a hash that matches one of the cookbooks/_attribute_files style
    # remote file listings.
    #
    # === Parameters
    # cookbook<Chef::Cookbook>:: The cookbook to update
    # valid_cache_entries<Hash>:: Out-param; Added to this hash are the files that
    # were referred to by this cookbook
    def self.sync_cookbook_file_cache(cookbook)
      Chef::Log.debug("Synchronizing cookbook #{cookbook.name}")

      # files and templates are lazily loaded, and will be done later.
      eager_segments = COOKBOOK_SEGMENTS.dup
      eager_segments.delete(:files)
      eager_segments.delete(:templates)

      eager_segments.each do |segment|
        segment_filenames = Array.new
        cookbook.manifest[segment].each do |manifest_record|
          # segment = cookbook segment
          # remote_list = list of file hashes
          #
          # We need the list of known good attribute files, so we can delete any that are
          # just laying about.

          cache_filename = File.join("cookbooks", cookbook.name, manifest_record['path'])
          valid_cache_entries[cache_filename] = true

          current_checksum = nil
          if cache.has_key?(cache_filename)
            current_checksum = checksum_cookbook_file(cache.load(cache_filename, false))
          end

          # If the checksums are different between on-disk (current) and on-server
          # (remote, per manifest), do the update. This will also execute if there
          # is no current checksum.
          if current_checksum != manifest_record['checksum']
            raw_file = chef_server_rest.get_rest(manifest_record[:url], true)

            Chef::Log.info("Storing updated #{cache_filename} in the cache.")
            cache.move_to(raw_file.path, cache_filename)
          else
            Chef::Log.debug("Not storing #{cache_filename}, as the cache is up to date.")
          end

          # make the segment filenames a full path.
          full_path_cache_filename = cache.load(cache_filename, false)
          segment_filenames << full_path_cache_filename
        end

        # replace segment filenames with a full-path one.
        if segment.to_sym == :recipes
          cookbook.recipe_filenames = segment_filenames
        elsif segment.to_sym == :attributes
          cookbook.attribute_filenames = segment_filenames
        else
          cookbook.segment_filenames(segment).replace(segment_filenames)
        end
      end
    end

    def self.cleanup_file_cache
      unless Chef::Config[:solo]
        # Delete each file in the cache that we didn't encounter in the
        # manifest.
        cache.find(File.join(%w{cookbooks ** *})).each do |cache_filename|
          unless valid_cache_entries[cache_filename]
            Chef::Log.info("Removing #{cache_filename} from the cache; it is no longer on the server.")
            cache.delete(cache_filename)
          end
        end
      end
    end

    # Register a notification to cleanup unused files from cookbooks
    Chef::Client.when_run_completes_successfully do |run_status|
      cleanup_file_cache
    end

    # Creates a new Chef::CookbookVersion object.  
    #
    # === Returns
    # object<Chef::CookbookVersion>:: Duh. :)
    def initialize(name, couchdb=nil)
      @name = name
      @attribute_filenames = Array.new
      @definition_filenames = Array.new
      @template_filenames = Array.new
      @file_filenames = Array.new
      @recipe_filenames = Array.new
      @recipe_filenames_by_name = Hash.new
      @library_filenames = Array.new
      @resource_filenames = Array.new
      @provider_filenames = Array.new
      @metadata_filenames = Array.new
      @root_dir = nil
      @root_filenames = Array.new
      @couchdb_id = nil
      @couchdb = couchdb || Chef::CouchDB.new
      @couchdb_rev = nil
      @status = :ready
      @manifest = nil
      @file_vendor = nil
      @metadata = Chef::Cookbook::Metadata.new
    end

    def version
      metadata.version
    end
    
    def version=(new_version)
      manifest["version"] = new_version
      metadata.version(new_version)
    end

    # A manifest is a Mash that maps segment names to arrays of manifest
    # records (see #preferred_manifest_record for format of manifest records),
    # as well as describing cookbook metadata. The manifest follows a form
    # like the following:
    #
    #   {
    #     :cookbook_name = "apache2",
    #     :version = "1.0",
    #     :name = "Apache 2"
    #     :metadata = ???TODO: timh/cw: 5-24-2010: describe this format,
    #   
    #     :files => [
    #       {
    #         :name => "afile.rb",
    #         :path => "files/ubuntu-9.10/afile.rb",
    #         :checksum => "2222",
    #         :specificity => "ubuntu-9.10"
    #       },
    #     ],
    #     :templates => [ manifest_record1, ... ],
    #     ...
    #   }
    def manifest
      unless @manifest
        generate_manifest
      end
      @manifest
    end
    
    def manifest=(new_manifest)
      @manifest = Mash.new new_manifest
      @checksums = extract_checksums_from_manifest(@manifest)
      @manifest_records_by_path = extract_manifest_records_by_path(@manifest)

      COOKBOOK_SEGMENTS.each do |segment|
        next unless @manifest.has_key?(segment)
        filenames = @manifest[segment].map{|manifest_record| manifest_record['name']}
        
        if segment == :recipes
          self.recipe_filenames = filenames
        elsif segment == :attributes
          self.attribute_filenames = filenames
        else
          segment_filenames(segment).clear
          filenames.each { |filename| segment_filenames(segment) << filename }
        end
      end
    end
    
    # Returns a hash of checksums to either nil or the on disk path (which is
    # done by generate_manifest).
    def checksums
      unless @checksums
        generate_manifest
      end
      @checksums
    end

    def full_name
      "#{name}-#{version}"
    end
    
    def attribute_filenames=(*filenames)
      @attribute_filenames = filenames.flatten
      @attribute_filenames_by_short_filename = filenames_by_name(attribute_filenames)
      attribute_filenames
    end
    
    ## BACKCOMPAT/DEPRECATED - Remove these and fix breakage before release [DAN - 5/20/2010]##
    alias :attribute_files :attribute_filenames
    alias :attribute_files= :attribute_filenames=
    
    # Return recipe names in the form of cookbook_name::recipe_name
    def fully_qualified_recipe_names
      results = Array.new
      recipe_filenames_by_name.each_key do |rname|
        results << "#{name}::#{rname}"
      end
      results
    end
    
    def recipe_filenames=(*filenames)
      @recipe_filenames = filenames.flatten
      @recipe_filenames_by_name = filenames_by_name(recipe_filenames)
      recipe_filenames
    end
    
    ## BACKCOMPAT/DEPRECATED - Remove these and fix breakage before release [DAN - 5/20/2010]##
    alias :recipe_files :recipe_filenames
    alias :recipe_files= :recipe_filenames=
    
    # called from DSL
    def load_recipe(recipe_name, run_context)
      unless recipe_filenames_by_name.has_key?(recipe_name)
        raise ArgumentError, "Cannot find a recipe matching #{recipe_name} in cookbook #{name}"
      end

      Chef::Log.debug("Found recipe #{recipe_name} in cookbook #{name}")
      recipe = Chef::Recipe.new(name, recipe_name, run_context)
      recipe_filename = recipe_filenames_by_name[recipe_name]

      unless recipe_filename
        raise Chef::Exceptions::RecipeNotFound, "could not find recipe #{recipe_name} for cookbook #{name}"
      end
      
      recipe.from_file(recipe_filename)
      recipe
    end

    def segment_filenames(segment)
      unless COOKBOOK_SEGMENTS.include?(segment)
        raise ArgumentError, "invalid segment #{segment}: must be one of #{COOKBOOK_SEGMENTS.join(', ')}"
      end

      case segment.to_sym
      when :resources
        @resource_filenames
      when :providers
        @provider_filenames
      when :recipes
        @recipe_filenames
      when :libraries
        @library_filenames
      when :definitions
        @definition_filenames
      when :attributes
        @attribute_filenames
      when :files
        @file_filenames
      when :templates
        @template_filenames
      when :root_files
        @root_filenames
      end
    end

    # Determine the most specific manifest record for the given
    # segment/filename, given information in the node. Throws
    # FileNotFound if there is no such segment and filename in the
    # manifest.
    #
    # A manifest record is a Mash that follows the following form:
    # {
    #   :name => "example.rb",
    #   :path => "files/default/example.rb",
    #   :specificity => "default",
    #   :checksum => "1234"
    # }
    def preferred_manifest_record(node, segment, filename)
      preferences = preferences_for_path(node, segment, filename)

      # ensure that we generate the manifest, which will also generate
      # @manifest_records_by_path
      manifest
      
      # in order of prefernce, look for the filename in the manifest
      found_pref = preferences.find {|preferred_filename| @manifest_records_by_path[preferred_filename] }
      if found_pref
        @manifest_records_by_path[found_pref]
      else
        raise Chef::Exceptions::FileNotFound, "cookbook #{name} does not contain file #{segment}/#{filename}"
      end
    end
    
    def preferred_filename_on_disk_location(node, segment, filename, current_filepath=nil)
      manifest_record = preferred_manifest_record(node, segment, filename)
      if current_filepath && (manifest_record['checksum'] == self.class.checksum_cookbook_file(current_filepath))
        nil
      else
        file_vendor.get_filename(manifest_record['path'])
      end
    end

    def relative_filenames_in_preferred_directory(node, segment, dirname)
      preferences = preferences_for_path(node, segment, dirname)
      filenames_by_pref = Hash.new
      preferences.each { |pref| filenames_by_pref[pref] = Array.new }

      manifest[segment].each do |manifest_record|
        manifest_record_path = manifest_record[:path]

        # find the NON SPECIFIC filenames, but prefer them by filespecificity.
        # For example, if we have a file:
        # 'files/default/somedir/somefile.conf' we only keep
        # 'somedir/somefile.conf'. If there is also
        # 'files/$hostspecific/somedir/otherfiles' that matches the requested
        # hostname specificity, that directory will win, as it is more specific.
        #
        # This is clearly ugly b/c the use case is for remote directory, where
        # we're just going to make cookbook_files out of these and make the
        # cookbook find them by filespecificity again. but it's the shortest
        # path to "success" for now.
        if manifest_record_path =~ /(#{Regexp.escape(segment.to_s)}\/[^\/]+\/#{Regexp.escape(dirname)})\/.+$/
          specificity_dirname = $1
          non_specific_path = manifest_record_path[/#{Regexp.escape(segment.to_s)}\/[^\/]+\/#{Regexp.escape(dirname)}\/(.+)$/, 1]
          # Record the specificity_dirname only if it's in the list of
          # valid preferences
          if filenames_by_pref[specificity_dirname]
            filenames_by_pref[specificity_dirname] << non_specific_path
          end
        end
      end

      best_pref = preferences.find { |pref| !filenames_by_pref[pref].empty? }

      raise Chef::Exceptions::FileNotFound, "cookbook #{name} has no directory #{segment}/#{dirname}" unless best_pref

      filenames_by_pref[best_pref]

    end

    # Determine the manifest records from the most specific directory
    # for the given node. See #preferred_manifest_record for a
    # description of entries of the returned Array.
    def preferred_manifest_records_for_directory(node, segment, dirname)
      preferences = preferences_for_path(node, segment, dirname)
      records_by_pref = Hash.new
      preferences.each { |pref| records_by_pref[pref] = Array.new }

      manifest[segment].each do |manifest_record|
        manifest_record_path = manifest_record[:path]

        # extract the preference part from the path.
        if manifest_record_path =~ /(#{Regexp.escape(segment.to_s)}\/[^\/]+\/#{Regexp.escape(dirname)})\/.+$/
          # Note the specificy_dirname includes the segment and
          # dirname argument as above, which is what
          # preferences_for_path returns. It could be
          # "files/ubuntu-9.10/dirname", for example.
          specificity_dirname = $1
          
          # Record the specificity_dirname only if it's in the list of
          # valid preferences
          if records_by_pref[specificity_dirname]
            records_by_pref[specificity_dirname] << manifest_record
          end
        end
      end
      
      best_pref = preferences.find { |pref| !records_by_pref[pref].empty? }
        
      raise Chef::Exceptions::FileNotFound, "cookbook #{name} has no directory #{segment}/#{dirname}" unless best_pref

      records_by_pref[best_pref]
    end


    # Given a node, segment and path (filename or directory name),
    # return the priority-ordered list of preference locations to
    # look.
    def preferences_for_path(node, segment, path)
      # only files and templates can be platform-specific
      if segment.to_sym == :files || segment.to_sym == :templates
        begin
          platform, version = Chef::Platform.find_platform_and_version(node)
        rescue ArgumentError => e
          # Skip platform/version if they were not found by find_platform_and_version
          if e.message =~ /Cannot find a (?:platform|version)/
            platform = "/unknown_platform/"
            version = "/unknown_platform_version/"
          else
            raise
          end
        end
        
        fqdn = node[:fqdn]

        # Most specific to least specific places to find the path
        [
         File.join(segment.to_s, "host-#{fqdn}", path),
         File.join(segment.to_s, "#{platform}-#{version}", path),
         File.join(segment.to_s, platform.to_s, path),
         File.join(segment.to_s, "default", path)
        ]
      else
        [File.join(segment, path)]
      end
    end
    private :preferences_for_path

    def to_hash
      result = manifest.dup
      result['chef_type'] = 'cookbook_version'
      result["_rev"] = couchdb_rev if couchdb_rev
      result.to_hash
    end

    def to_json(*a)
      result = self.to_hash
      result['json_class'] = self.class.name
      result.to_json(*a)
    end

    def self.json_create(o)
      cookbook_version = new(o["cookbook_name"])
      if o.has_key?('_rev')
        cookbook_version.couchdb_rev = o["_rev"] if o.has_key?("_rev")
        o.delete("_rev")
      end
      if o.has_key?("_id")
        cookbook_version.couchdb_id = o["_id"] if o.has_key?("_id")
        cookbook_version.index_id = cookbook_version.couchdb_id
        o.delete("_id")
      end
      cookbook_version.manifest = o
      # We want the Chef::Cookbook::Metadata object to always be inflated
      cookbook_version.metadata = Chef::Cookbook::Metadata.from_hash(o["metadata"])
      cookbook_version
    end
    
    def generate_manifest_with_urls(&url_generator)
      rendered_manifest = manifest.dup
      COOKBOOK_SEGMENTS.each do |segment|
        if rendered_manifest.has_key?(segment)
          rendered_manifest[segment].each do |manifest_record|
            url_options = { :cookbook_name => name.to_s, :cookbook_version => version, :checksum => manifest_record["checksum"] }
            manifest_record["url"] = url_generator.call(url_options)
          end
        end
      end
      rendered_manifest
    end

    def metadata_json_file
      File.join(root_dir, "metadata.json")
    end

    def metadata_rb_file
      File.join(root_dir, "metadata.rb")
    end

    def reload_metadata!
      if File.exists?(metadata_json_file)
        metadata.from_json(IO.read(metadata_json_file))
      end
    end

    ##
    # REST API
    ##
    def self.chef_server_rest
      Chef::REST.new(Chef::Config[:chef_server_url])
    end

    def chef_server_rest
      self.class.chef_server_rest
    end

    def save
      chef_server_rest.put_rest("cookbooks/#{name}/#{version}", self)
      self
    end
    alias :create :save

    def destroy
      chef_server_rest.delete_rest("cookbooks/#{name}/#{version}")
      self
    end

    def self.load(name, version="_latest")
      version = "_latest" if version == "latest"
      chef_server_rest.get_rest("cookbooks/#{name}/#{version}")
    end

    def self.list
      chef_server_rest.get_rest('cookbooks')
    end

    ##
    # Given a +cookbook_name+, get a list of all versions that exist on the
    # server.
    # ===Returns
    # [String]::  Array of cookbook versions, which are strings like 'x.y.z'
    # nil::       if the cookbook doesn't exist. an error will also be logged.
    def self.available_versions(cookbook_name)
      chef_server_rest.get_rest("cookbooks/#{cookbook_name}").values.flatten
    rescue Net::HTTPServerException => e
      if e.to_s =~ /^404/
        Chef::Log.error("Cannot find a cookbook named #{cookbook_name}")
        nil
      else
        raise
      end
    end

    # Get the newest version of all cookbooks
    def self.latest_cookbooks
      chef_server_rest.get_rest('cookbooks/_latest')
    end

    ##
    # Couchdb
    ##
    
    def self.cdb_by_name(cookbook_name, couchdb=nil)
      cdb = (couchdb || Chef::CouchDB.new)
      options = { :startkey => cookbook_name, :endkey => cookbook_name }
      rs = cdb.get_view("cookbooks", "all_with_version", options)
      rs["rows"].inject({}) { |memo, row| memo.has_key?(row["key"]) ? memo[row["key"]] << row["value"] : memo[row["key"]] = [ row["value"] ]; memo }
    end

    def self.create_design_document(couchdb=nil)
      (couchdb || Chef::CouchDB.new).create_design_document("cookbooks", DESIGN_DOCUMENT)
    end

    def self.cdb_list_latest(inflate=false, couchdb=nil)
      couchdb ||= Chef::CouchDB.new
      if inflate
        doc_ids = cdb_list_latest_ids.map {|i|i["id"]}
        couchdb.bulk_get(doc_ids)
      else
        results = couchdb.get_view("cookbooks", "all_latest_version", :group=>true)["rows"]
        results.inject({}) { |mapped, row| mapped[row["key"]] = row["value"]; mapped}
      end
    end

    def self.cdb_list_latest_ids(inflate=false, couchdb=nil)
      couchdb ||= Chef::CouchDB.new
      results = couchdb.get_view("cookbooks", "all_latest_version_by_id", :group=>true)["rows"]
      results.map { |name_and_id| name_and_id["value"]}
    end

    def self.cdb_list(inflate=false, couchdb=nil)
      rs = (couchdb || Chef::CouchDB.new).list("cookbooks", inflate)
      lookup = (inflate ? "value" : "key")
      rs["rows"].collect { |r| r[lookup] }            
    end

    def self.cdb_load(name, version='latest', couchdb=nil)
      cdb = couchdb || Chef::CouchDB.new
      if version == "latest" || version == "_latest"
        rs = cdb.get_view("cookbooks", "all_latest_version", :key => name, :descending => true, :group => true, :reduce => true)["rows"].first
        cdb.load("cookbook_version", "#{rs["key"]}-#{rs["value"]}")
      else
        cdb.load("cookbook_version", "#{name}-#{version}")
      end
    end

    def cdb_destroy
      (couchdb || Chef::CouchDB.new).delete("cookbook_version", full_name, couchdb_rev)
    end

    # Runs on Chef Server (API); deletes the cookbook from couchdb and also destroys associated
    # checksum documents 
    def purge
      checksums.keys.each do |checksum|
        Chef::Checksum.cdb_load(checksum, couchdb).purge
      end
      cdb_destroy
    end

    def cdb_save
      @couchdb_rev = couchdb.store("cookbook_version", full_name, self)["rev"]
    end

    def couchdb_id=(value)
      @couchdb_id = value
      @index_id = value
    end

    private
    
    # For each filename, produce a mapping of base filename (i.e. recipe name
    # or attribute file) to on disk location
    def filenames_by_name(filenames)
      filenames.select{|filename| filename =~ /\.rb$/}.inject({}){|memo, filename| memo[File.basename(filename, '.rb')] = filename ; memo }
    end

    # See #manifest for a description of the manifest return value.
    # See #preferred_manifest_record for a description an individual manifest record.
    def generate_manifest
      manifest = Mash.new({
        :recipes => Array.new,
        :definitions => Array.new,
        :libraries => Array.new,
        :attributes => Array.new,
        :files => Array.new,
        :templates => Array.new,
        :resources => Array.new,
        :providers => Array.new,
        :root_files => Array.new
      })
      checksums_to_on_disk_paths = {}

      COOKBOOK_SEGMENTS.each do |segment|
        segment_filenames(segment).each do |segment_file|
          next if File.directory?(segment_file)

          file_name = nil
          path = nil
          specificity = "default"
          
          if segment == :root_files
            matcher = segment_file.match(".+/#{Regexp.escape(name.to_s)}/(.+)")
            file_name = matcher[1]
            path = file_name
          elsif segment == :templates || segment == :files
            matcher = segment_file.match("/#{Regexp.escape(name.to_s)}/(#{Regexp.escape(segment.to_s)}/(.+?)/(.+))")
            unless matcher
              Chef::Log.debug("Skipping file #{segment_file}, as it doesn't have a proper segment.")
              next
            end
            path = matcher[1]
            specificity = matcher[2]
            file_name = matcher[3]
          else
            matcher = segment_file.match("/#{Regexp.escape(name.to_s)}/(#{Regexp.escape(segment.to_s)}/(.+))")
            path = matcher[1]
            file_name = matcher[2]
          end
          
          csum = self.class.checksum_cookbook_file(segment_file)
          checksums_to_on_disk_paths[csum] = segment_file
          rs = Mash.new({
            :name => file_name,
            :path => path,
            :checksum => csum
          })
          rs[:specificity] = specificity

          manifest[segment] << rs
        end
      end

      manifest[:cookbook_name] = name.to_s
      manifest[:metadata] = metadata
      manifest[:version] = metadata.version
      manifest[:name] = full_name

      @checksums = checksums_to_on_disk_paths
      @manifest = manifest
      @manifest_records_by_path = extract_manifest_records_by_path(manifest)
    end
    
    def file_vendor
      unless @file_vendor
        @file_vendor = Chef::Cookbook::FileVendor.create_from_manifest(manifest)
      end
      @file_vendor
    end

    def extract_checksums_from_manifest(manifest)
      checksums = {}
      COOKBOOK_SEGMENTS.each do |segment|
        next unless manifest.has_key?(segment)
        manifest[segment].each do |manifest_record|
          checksums[manifest_record[:checksum]] = nil
        end
      end
      checksums
    end
    
    def extract_manifest_records_by_path(manifest)
      manifest_records_by_path = {}
      COOKBOOK_SEGMENTS.each do |segment|
        next unless manifest.has_key?(segment)
        manifest[segment].each do |manifest_record|
          manifest_records_by_path[manifest_record[:path]] = manifest_record
        end
      end
      manifest_records_by_path
    end
    
  end
end
