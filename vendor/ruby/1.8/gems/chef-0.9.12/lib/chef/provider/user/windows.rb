#
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Copyright:: Copyright (c) 2010 VMware, Inc.
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

require 'chef/provider/user'
if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'chef/util/windows/net_user'
end

class Chef
  class Provider
    class User
      class Windows < Chef::Provider::User

        def initialize(new_resource,run_context)
          super
          @net_user = Chef::Util::Windows::NetUser.new(@new_resource.name)
        end

        def load_current_resource
          @current_resource = Chef::Resource::User.new(@new_resource.name)
          @current_resource.username(@new_resource.username)
          user_info = nil
          begin
            user_info = @net_user.get_info
          rescue
            @user_exists = false
            Chef::Log.debug("User #{@new_resource.username} does not exist")
          end

          if user_info
            @current_resource.uid(user_info[:user_id])
            @current_resource.gid(user_info[:primary_group_id])
            @current_resource.comment(user_info[:full_name])
            @current_resource.home(user_info[:home_dir])
            @current_resource.shell(user_info[:script_path])
          end

          @current_resource
        end

        # Check to see if the user needs any changes
        #
        # === Returns
        # <true>:: If a change is required
        # <false>:: If the users are identical
        def compare_user
          unless @net_user.validate_credentials(@new_resource.password)
            Chef::Log.debug("User #{@new_resource.username} password has changed")
            return true
          end
          [ :uid, :gid, :comment, :home, :shell ].any? do |user_attrib|
            !@new_resource.send(user_attrib).nil? && @new_resource.send(user_attrib) != @current_resource.send(user_attrib)
          end
        end

        def create_user
          @net_user.add(set_options)
        end
        
        def manage_user
          @net_user.update(set_options)
        end
        
        def remove_user
          @net_user.delete
        end
        
        def check_lock
          @net_user.check_enabled
        end
        
        def lock_user
          @net_user.disable_account
        end
        
        def unlock_user
          @net_user.enable_account
        end

        def set_options
          opts = {:name => @new_resource.username}

          field_list = {
            'comment' => 'full_name',
            'home' => 'home_dir',
            'gid' => 'primary_group_id',
            'uid' => 'user_id',
            'shell' => 'script_path',
            'password' => 'password'
          }

          field_list.sort{ |a,b| a[0] <=> b[0] }.each do |field, option|
            field_symbol = field.to_sym
            if @current_resource.send(field_symbol) != @new_resource.send(field_symbol)
              if @new_resource.send(field_symbol)
                unless field_symbol == :password
                  Chef::Log.debug("Setting #{@new_resource} #{field} to #{@new_resource.send(field_symbol)}")
                end
                opts[option.to_sym] = @new_resource.send(field_symbol)
              end
            end
          end
          opts
        end

      end
    end
  end
end
