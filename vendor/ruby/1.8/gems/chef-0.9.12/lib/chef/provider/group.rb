#
# Author:: AJ Christensen (<aj@opscode.com>)
# Copyright:: Copyright (c) 2008 OpsCode, Inc.
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

require 'chef/provider'
require 'chef/mixin/command'
require 'chef/resource/group'
require 'etc'

class Chef
  class Provider
    class Group < Chef::Provider
      include Chef::Mixin::Command
      attr_accessor :group_exists
      
      def initialize(new_resource, run_context)
        super
        @group_exists = true
      end
      
      def load_current_resource
        @current_resource = Chef::Resource::Group.new(@new_resource.name)
        @current_resource.group_name(@new_resource.group_name)
        
        group_info = nil
        begin
          group_info = Etc.getgrnam(@new_resource.group_name)
        rescue ArgumentError => e
          @group_exists = false
          Chef::Log.debug("#{@new_resource}: group does not exist")
        end
        
        if group_info
          @new_resource.gid(group_info.gid) unless @new_resource.gid
          @current_resource.gid(group_info.gid)
          @current_resource.members(group_info.mem)
        end
        
        @current_resource
      end
      
      # Check to see if a group needs any changes
      #
      # ==== Returns
      # <true>:: If a change is required
      # <false>:: If a change is not required
      def compare_group
        return true if @new_resource.gid != @current_resource.gid

        if(@new_resource.append)
          @new_resource.members.each do |member|
            next if @current_resource.members.include?(member)
            return true
          end
        else
          return true if @new_resource.members != @current_resource.members
        end

        return false
      end
      
      def action_create
        case @group_exists
        when false
          create_group
          Chef::Log.info("Created #{@new_resource}")
          @new_resource.updated_by_last_action(true)
        else 
          if compare_group
            manage_group
            Chef::Log.info("Altered #{@new_resource}")
            @new_resource.updated_by_last_action(true)
          end
        end
      end
      
      def action_remove
        if @group_exists
          remove_group
          @new_resource.updated_by_last_action(true)
          Chef::Log.info("Removed #{@new_resource}")
        end
      end
      
      def action_manage
        if @group_exists && compare_group
          manage_group 
          @new_resource.updated_by_last_action(true)
          Chef::Log.info("Managed #{@new_resource}")
        end
      end
      
      def action_modify
        if @group_exists 
          if compare_group
            manage_group
            @new_resource.updated_by_last_action(true)
            Chef::Log.info("Modified #{@new_resource}")
          end
        else
          raise Chef::Exceptions::Group, "Cannot modify #{@new_resource} - group does not exist!"
        end
      end
      
      def create_group
        raise NotImplementedError, "subclasses of Chef::Provider::Group should define #create_group"
      end

      def manage_group
        raise NotImplementedError, "subclasses of Chef::Provider::Group should define #manage_group"
      end

      def remove_group
        raise NotImplementedError, "subclasses of Chef::Provider::Group should define #remove_group"
      end

    end
  end
end
