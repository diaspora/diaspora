#
# Author:: Adam Jacob (<adam@opscode.com>)
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

require 'chef/mixin/command'
require 'chef/log'
require 'chef/file_cache'
require 'chef/resource/remote_file'
require 'chef/platform'

class Chef
  class Provider
    class Package < Chef::Provider
      
      include Chef::Mixin::Command
      
      attr_accessor :candidate_version
      
      def initialize(new_resource, run_context)
        super
        @candidate_version = nil
      end
      
      def action_install  
        # If we specified a version, and it's not the current version, move to the specified version
        if @new_resource.version != nil && @new_resource.version != @current_resource.version
          install_version = @new_resource.version
        # If it's not installed at all, install it
        elsif @current_resource.version == nil
          install_version = candidate_version
        else
          return
        end

        unless install_version
          raise(Chef::Exceptions::Package, "No version specified, and no candidate version available for #{@new_resource.package_name}")
        end

        Chef::Log.info("Installing #{@new_resource} version #{install_version}")
          
        # We need to make sure we handle the preseed file
        if @new_resource.response_file
          preseed_package(@new_resource.package_name, install_version)
        end
          
        status = install_package(@new_resource.package_name, install_version)
        if status
          @new_resource.updated_by_last_action(true)
        end
      end
      
      def action_upgrade
        if @current_resource.version != candidate_version
          orig_version = @current_resource.version || "uninstalled"
          Chef::Log.info("Upgrading #{@new_resource} version from #{orig_version} to #{candidate_version}")
          status = upgrade_package(@new_resource.package_name, candidate_version)
          if status
            @new_resource.updated_by_last_action(true)
          end
        end
      end
      
      def action_remove        
        if removing_package?
          Chef::Log.info("Removing #{@new_resource}")
          remove_package(@current_resource.package_name, @new_resource.version)
          @new_resource.updated_by_last_action(true)
        else
        end
      end
      
      def removing_package?
        if @current_resource.version.nil?
          false # nothing to remove
        elsif @new_resource.version.nil?
          true # remove any version of a package
        elsif @new_resource.version == @current_resource.version
          true # remove the version we have
        else
          false # we don't have the version we want to remove
        end
      end
      
      def action_purge
        if removing_package?
          Chef::Log.info("Purging #{@new_resource}")
          purge_package(@current_resource.package_name, @new_resource.version)
          @new_resource.updated_by_last_action(true)
        end
      end
      
      def install_package(name, version)
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :install"
      end
      
      def upgrade_package(name, version)
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :upgrade" 
      end
      
      def remove_package(name, version)
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :remove" 
      end
      
      def purge_package(name, version)
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :purge" 
      end
      
      def preseed_package(name, version)
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support pre-seeding package install/upgrade instructions - don't ask it to!" 
      end
      
      def get_preseed_file(name, version)
        resource = preseed_resource(name, version)
        Chef::Log.debug("Fetching preseed file to #{resource.path}")
        resource.run_action('create')
        
        if resource.updated_by_last_action?
          resource.path
        else
          false
        end
      end
      
      def preseed_resource(name, version)
        # A directory in our cache to store this cookbook's preseed files in
        file_cache_dir = Chef::FileCache.create_cache_path("preseed/#{@new_resource.cookbook_name}")
        # The full path where the preseed file will be stored
        cache_seed_to = "#{file_cache_dir}/#{name}-#{version}.seed"

        Chef::Log.debug("Fetching preseed file to #{cache_seed_to}")

        remote_file = Chef::Resource::CookbookFile.new(cache_seed_to, run_context)
        remote_file.cookbook_name = @new_resource.cookbook_name
        remote_file.source(@new_resource.response_file)
        remote_file.backup(false)
        
        remote_file
      end

      def expand_options(options)
        options ? " #{options}" : ""
      end
      
    end
  end
end
