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

require 'chef/provider/mount'
if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'chef/util/windows/net_use'
  require 'chef/util/windows/volume'
end

class Chef
  class Provider
    class Mount
      class Windows < Chef::Provider::Mount

        def is_volume(name)
          name =~ /^\\\\\?\\Volume\{[\w-]+\}\\$/ ? true : false
        end

        def initialize(new_resource, run_context)
          super
          @mount = nil
        end

        def load_current_resource
          if is_volume(@new_resource.device)
            @mount = Chef::Util::Windows::Volume.new(@new_resource.name)
          else #assume network drive
            @mount = Chef::Util::Windows::NetUse.new(@new_resource.name)
          end

          @current_resource = Chef::Resource::Mount.new(@new_resource.name)
          @current_resource.mount_point(@new_resource.mount_point)
          Chef::Log.debug("Checking for mount point #{@current_resource.mount_point}")

          begin
            @current_resource.device(@mount.device)
            Chef::Log.debug("#{@current_resource.device} mounted on #{@new_resource.mount_point}")
            @current_resource.mounted(true)
          rescue ArgumentError => e
            @current_resource.mounted(false)
            Chef::Log.debug("#{@new_resource.mount_point} is not mounted: #{e.message}")
          end
        end

        def mount_fs
          unless @current_resource.mounted
            @mount.add(@new_resource.device)
          else
            Chef::Log.debug("#{@new_resource.mount_point} is already mounted.")
          end
        end

        def umount_fs
          if @current_resource.mounted
            @mount.delete
            Chef::Log.info("Unmounted #{@new_resource.mount_point}")
          else
            Chef::Log.debug("#{@new_resource.mount_point} is not mounted.")
          end
        end

      end
    end
  end
end
