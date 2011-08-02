#
# Author:: Stephen Haynes (<sh@nomitor.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

class Chef
  class Provider
    class Group
      class Pw < Chef::Provider::Group
        
        def load_current_resource
          super
          raise Chef::Exceptions::Group, "Could not find binary /usr/sbin/pw for #{@new_resource}" unless ::File.exists?("/usr/sbin/pw")
        end
        
        # Create the group
        def create_group
          command = "pw groupadd"
          command << set_options
          command << set_members_option
          run_command(:command => command)
        end
        
        # Manage the group when it already exists
        def manage_group
          command = "pw groupmod"
          command << set_options
          command << set_members_option
          run_command(:command => command)
        end
        
        # Remove the group
        def remove_group
          run_command(:command => "pw groupdel #{@new_resource.group_name}")
        end
        
        # Little bit of magic as per Adam's useradd provider to pull and assign the command line flags
        #
        # ==== Returns
        # <string>:: A string containing the option and then the quoted value
        def set_options
          opts = " #{@new_resource.group_name}"
          if @new_resource.gid && (@current_resource.gid != @new_resource.gid)
            Chef::Log.debug("#{@new_resource}: current gid (#{@current_resource.gid}) doesnt match target gid (#{@new_resource.gid}), changing it")
            opts << " -g '#{@new_resource.gid}'"
          end
          opts
        end

        # Set the membership option depending on the current resource states
        def set_members_option
          opt = ""
          unless @new_resource.members.empty?
            opt << " -M #{@new_resource.members.join(',')}"
            Chef::Log.debug("#{@new_resource}: setting group members to #{@new_resource.members.join(', ')}")
          else
            # New member list is empty so we should delete any old group members
            unless @current_resource.members.empty?
              opt << " -d #{@current_resource.members.join(',')}"
              Chef::Log.debug("#{@new_resource}: removing group members #{@current_resource.members.join(', ')}")
            else
              Chef::Log.debug("#{@new_resource}: not changing group members, the group has no members")
            end
          end
          opt
        end
        
      end
    end
  end
end