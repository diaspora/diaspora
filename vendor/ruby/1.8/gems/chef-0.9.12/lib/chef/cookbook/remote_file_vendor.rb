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
#

require 'chef/cookbook/file_vendor'

class Chef
  class Cookbook
    # == Chef::Cookbook::RemoteFileVendor
    # This FileVendor loads files by either fetching them from the local cache, or
    # if not available, loading them from the remote server.
    class RemoteFileVendor < FileVendor
      
      def initialize(manifest, rest)
        @manifest = manifest
        @cookbook_name = @manifest[:cookbook_name]
        @rest = rest
      end
      
      # Implements abstract base's requirement. It looks in the
      # Chef::Config.cookbook_path file hierarchy for the requested
      # file.
      def get_filename(filename)
        if filename =~ /([^\/]+)\/(.+)$/
          segment = $1
        else
          raise "get_filename: Cannot determine segment/filename for incoming filename #{filename}"
        end
        
        raise "No such segment #{segment} in cookbook #{@cookbook_name}" unless @manifest[segment]
        found_manifest_record = @manifest[segment].find {|manifest_record| manifest_record[:path] == filename }
        raise "No such file #{filename} in #{@cookbook_name}" unless found_manifest_record
        
        cache_filename = File.join("cookbooks", @cookbook_name, found_manifest_record['path'])
        
        # update valid_cache_entries so the upstream cache cleaner knows what
        # we've used.
        validate_cached_copy(cache_filename)

        current_checksum = nil
        if Chef::FileCache.has_key?(cache_filename)
          current_checksum = Chef::CookbookVersion.checksum_cookbook_file(Chef::FileCache.load(cache_filename, false))
        end

        # If the checksums are different between on-disk (current) and on-server
        # (remote, per manifest), do the update. This will also execute if there
        # is no current checksum.
        if current_checksum != found_manifest_record['checksum']
          raw_file = @rest.get_rest(found_manifest_record[:url], true)

          Chef::Log.info("Storing updated #{cache_filename} in the cache.")
          Chef::FileCache.move_to(raw_file.path, cache_filename)
        else
          Chef::Log.debug("Not storing #{cache_filename}, as the cache is up to date.")
        end

        full_path_cache_filename = Chef::FileCache.load(cache_filename, false)

        # return the filename, not the contents (second argument= false)
        full_path_cache_filename
      end

      def validate_cached_copy(cache_filename)
        valid_cache_entries[cache_filename] = true
      end

      def valid_cache_entries
        Chef::CookbookVersion.valid_cache_entries
      end
      
    end
  end
end
