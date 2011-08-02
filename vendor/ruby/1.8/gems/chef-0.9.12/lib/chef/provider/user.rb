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

require 'chef/provider'
require 'chef/mixin/command'
require 'chef/resource/user'
require 'etc'

class Chef
  class Provider
    class User < Chef::Provider
      
      include Chef::Mixin::Command
      
      attr_accessor :user_exists, :locked
      
      def initialize(new_resource, run_context)
        super
        @user_exists = true
        @locked = nil
      end
  
      def convert_group_name
        if @new_resource.gid.is_a? String
          @new_resource.gid(Etc.getgrnam(@new_resource.gid).gid)
        end
      rescue ArgumentError => e
        raise Chef::Exceptions::User, "Couldn't lookup integer GID for group name #{@new_resource.gid}"
      end
      
      def load_current_resource
        @current_resource = Chef::Resource::User.new(@new_resource.name)
        @current_resource.username(@new_resource.username)
      
        begin
          user_info = Etc.getpwnam(@new_resource.username)
        rescue ArgumentError => e
          @user_exists = false
          Chef::Log.debug("User #{@new_resource.username} does not exist")
          user_info = nil
        end
        
        if user_info
          @current_resource.uid(user_info.uid)
          @current_resource.gid(user_info.gid)
          @current_resource.comment(user_info.gecos)
          @current_resource.home(user_info.dir)
          @current_resource.shell(user_info.shell)
          @current_resource.password(user_info.passwd)
        
          if @new_resource.password && @current_resource.password == 'x'
            begin
              require 'shadow'
            rescue LoadError
              Chef::Log.error("You must have ruby-shadow installed for password support!")
              raise Chef::Exceptions::MissingLibrary, "You must have ruby-shadow installed for password support!"
            else
              shadow_info = Shadow::Passwd.getspnam(@new_resource.username)
              @current_resource.password(shadow_info.sp_pwdp)
            end
          end
          
          if @new_resource.gid
            convert_group_name
          end
        end
        
        @current_resource
      end

      # Check to see if the user needs any changes
      #
      # === Returns
      # <true>:: If a change is required
      # <false>:: If the users are identical
      def compare_user
        [ :uid, :gid, :comment, :home, :shell, :password ].any? do |user_attrib|
          !@new_resource.send(user_attrib).nil? && @new_resource.send(user_attrib) != @current_resource.send(user_attrib)
        end
      end
      
      def action_create
        if !@user_exists
          create_user
          Chef::Log.info("Created #{@new_resource}")
          @new_resource.updated_by_last_action(true)
        elsif compare_user
          manage_user
          Chef::Log.info("Altered #{@new_resource}")
          @new_resource.updated_by_last_action(true)
        end
      end
      
      def action_remove
        if @user_exists
          remove_user
          @new_resource.updated_by_last_action(true)
          Chef::Log.info("Removed #{@new_resource}")
        end
      end

      def remove_user
        raise NotImplementedError
      end

      def action_manage
        if @user_exists && compare_user
          manage_user
          @new_resource.updated_by_last_action(true)
          Chef::Log.info("Managed #{@new_resource}")
        end
      end

      def manage_user
        raise NotImplementedError
      end

      def action_modify
        if @user_exists
          if compare_user
            manage_user
            @new_resource.updated_by_last_action(true)
            Chef::Log.info("Modified #{@new_resource}")
          end
        else
          raise Chef::Exceptions::User, "Cannot modify #{@new_resource} - user does not exist!"
        end
      end

      def action_lock
        if @user_exists
          if check_lock() == false
            lock_user
            @new_resource.updated_by_last_action(true)
            Chef::Log.info("Locked #{@new_resource}")
          else
            Chef::Log.debug("No need to lock #{@new_resource}")
          end
        else
          raise Chef::Exceptions::User, "Cannot lock #{@new_resource} - user does not exist!"
        end
      end

      def check_lock
        raise NotImplementedError
      end

      def lock_user
        raise NotImplementedError
      end

      def action_unlock
        if @user_exists
          if check_lock() == true
            unlock_user
            @new_resource.updated_by_last_action(true)
            Chef::Log.info("Unlocked #{@new_resource}")
          else
            Chef::Log.debug("No need to unlock #{@new_resource}")
          end
        else
          raise Chef::Exceptions::User, "Cannot unlock #{@new_resource} - user does not exist!"
        end
      end
      
      def unlock_user
        raise NotImplementedError
      end

    end
  end
end
