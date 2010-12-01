#
# Author:: Daniel DeLeo (<dan@opscode.com>)
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

require 'chef/file_access_control'
require 'chef/provider/file'
require 'tempfile'

class Chef
  class Provider
    class CookbookFile < Chef::Provider::File
      
      def load_current_resource
        @current_resource = Chef::Resource::CookbookFile.new(@new_resource.name)
        @new_resource.path.gsub!(/\\/, "/") # for Windows
        @current_resource.path(@new_resource.path)
        @current_resource
      end


      def action_create
         if file_cache_location && content_stale?
           Chef::Log.debug("content of file #{@new_resource.path} requires update")
           backup_new_resource
           Tempfile.open(::File.basename(@new_resource.name)) do |staging_file|
             Chef::Log.debug("staging #{file_cache_location} to #{staging_file.path}")
             staging_file.close
             stage_file_to_tmpdir(staging_file.path)
             FileUtils.mv(staging_file.path, @new_resource.path)
           end
           @new_resource.updated_by_last_action(true)
         else
           set_all_access_controls(@new_resource.path)
         end
         @new_resource.updated_by_last_action?
       end

      def action_create_if_missing
        if ::File.exists?(@new_resource.path)
          Chef::Log.debug("File #{@new_resource.path} exists, taking no action.")
        else
          action_create
        end
      end
      
      def file_cache_location
        @file_cache_location ||= begin
          cookbook = run_context.cookbook_collection[resource_cookbook]
          cookbook.preferred_filename_on_disk_location(node, :files, @new_resource.source, @new_resource.path)
        end
      end
      
      # Determine the cookbook to get the file from. If new resource sets an 
      # explicit cookbook, use it, otherwise fall back to the implicit cookbook
      # i.e., the cookbook the resource was declared in.
      def resource_cookbook
        @new_resource.cookbook || @new_resource.cookbook_name
      end
      
      # Copy the file from the cookbook cache to a temporary location and then
      # set its file access control settings.
      def stage_file_to_tmpdir(staging_file_location)
        FileUtils.cp(file_cache_location, staging_file_location)
        set_all_access_controls(staging_file_location)
      end

      def set_all_access_controls(file)
        access_controls = Chef::FileAccessControl.new(@new_resource, file)
        access_controls.set_all
        @new_resource.updated_by_last_action(access_controls.modified?)
      end

      def backup_new_resource
        if ::File.exists?(@new_resource.path)
          Chef::Log.info "Backing up current file at #{@new_resource.path}"
          backup @new_resource.path
        end
      end

      def content_stale?
        ( ! ::File.exist?(@new_resource.path)) || ( ! compare_content)
      end

    end
  end
end