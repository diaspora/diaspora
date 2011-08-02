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

require 'chef/config'
require 'chef/log'
require 'chef/resource/directory'
require 'chef/provider'
require 'chef/provider/file'
require 'fileutils'

class Chef
  class Provider
    class Directory < Chef::Provider::File
      def load_current_resource
        @current_resource = Chef::Resource::Directory.new(@new_resource.name)
        @current_resource.path(@new_resource.path)
        if ::File.exist?(@current_resource.path) && ::File.directory?(@current_resource.path)
          cstats = ::File.stat(@current_resource.path)
          @current_resource.owner(cstats.uid)
          @current_resource.group(cstats.gid)
          @current_resource.mode("%o" % (cstats.mode & 007777))
        end
        @current_resource
      end      
      
      def action_create
        unless ::File.exists?(@new_resource.path)
          Chef::Log.info("Creating #{@new_resource} at #{@new_resource.path}")
          if @new_resource.recursive == true
            ::FileUtils.mkdir_p(@new_resource.path)
          else
            ::Dir.mkdir(@new_resource.path)
          end
          @new_resource.updated_by_last_action(true)
        end
        set_owner if @new_resource.owner != nil
        set_group if @new_resource.group != nil
        set_mode if @new_resource.mode != nil
      end
      
      def action_delete
        if ::File.directory?(@new_resource.path) && ::File.writable?(@new_resource.path)
          if @new_resource.recursive == true
            Chef::Log.info("Deleting #{@new_resource} recursively at #{@new_resource.path}")
            FileUtils.rm_rf(@new_resource.path)
          else
            Chef::Log.info("Deleting #{@new_resource} at #{@new_resource.path}")
            ::Dir.delete(@new_resource.path)
          end
          @new_resource.updated_by_last_action(true)
        else
          raise RuntimeError, "Cannot delete #{@new_resource} at #{@new_resource_path}!" if ::File.exists?(@new_resource.path)
        end
      end
    end
  end
end
