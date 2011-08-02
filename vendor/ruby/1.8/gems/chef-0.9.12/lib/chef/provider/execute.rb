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
require 'chef/provider'

class Chef
  class Provider
    class Execute < Chef::Provider
      
      include Chef::Mixin::Command
      
      def load_current_resource
        true
      end
      
      def action_run
        command_args = {
          :command => @new_resource.command,
          :command_string => @new_resource.to_s,
        }
        command_args[:creates] = @new_resource.creates if @new_resource.creates
        command_args[:only_if] = @new_resource.only_if if @new_resource.only_if
        command_args[:not_if] = @new_resource.not_if if @new_resource.not_if
        command_args[:timeout] = @new_resource.timeout if @new_resource.timeout
        command_args[:returns] = @new_resource.returns if @new_resource.returns
        command_args[:environment] = @new_resource.environment if @new_resource.environment
        command_args[:user] = @new_resource.user if @new_resource.user
        command_args[:group] = @new_resource.group if @new_resource.group
        command_args[:cwd] = @new_resource.cwd if @new_resource.cwd
        command_args[:umask] = @new_resource.umask if @new_resource.umask
        
        status = run_command(command_args)
        if status
          @new_resource.updated_by_last_action(true)
          Chef::Log.info("Ran #{@new_resource} successfully")
        end
      end
      
    end
  end
end
