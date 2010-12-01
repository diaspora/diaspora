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
  require 'chef/util/windows/net_group'
end

class Chef
  class Provider
    class Group
      class Windows < Chef::Provider::Group
        
        def initialize(new_resource,run_context)
          super
          @net_group = Chef::Util::Windows::NetGroup.new(@new_resource.name)
        end

        def load_current_resource
          @current_resource = Chef::Resource::Group.new(@new_resource.name)
          @current_resource.group_name(@new_resource.group_name)
        
          members = nil
          begin
            members = @net_group.local_get_members
          rescue => e
            @group_exists = false
            Chef::Log.debug("#{@new_resource}: group does not exist")
          end

          if members
            @current_resource.members(members)
          end

          @current_resource
        end
        
        def create_group
          @net_group.local_add
          manage_group
        end
        
        def manage_group
          if @new_resource.append
            begin
              #ERROR_MEMBER_IN_ALIAS if a member already exists in the group
              @net_group.local_add_members(@new_resource.members)
            rescue
              members = @new_resource.members + @current_resource.members
              @net_group.local_set_members(members.uniq)
            end
          else
            @net_group.local_set_members(@new_resource.members)
          end
        end
        
        def remove_group
          @net_group.local_delete
        end
        
      end
    end
  end
end
