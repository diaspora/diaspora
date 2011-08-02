#
# Author:: Dreamcat4 (<dreamcat4@gmail.com>)
# Copyright:: Copyright (c) 2009 OpsCode, Inc.
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
      class Dscl < Chef::Provider::Group

        def dscl(*args)
          host = "."
          stdout_result = ""; stderr_result = ""; cmd = "dscl #{host} -#{args.join(' ')}"
          status = popen4(cmd) do |pid, stdin, stdout, stderr|
            stdout.each { |line| stdout_result << line }
            stderr.each { |line| stderr_result << line }
          end
          return [cmd, status, stdout_result, stderr_result]
        end

        def safe_dscl(*args)
          result = dscl(*args)
          return "" if ( args.first =~ /^delete/ ) && ( result[1].exitstatus != 0 )
          raise(Chef::Exceptions::Group,"dscl error: #{result.inspect}") unless result[1].exitstatus == 0
          raise(Chef::Exceptions::Group,"dscl error: #{result.inspect}") if result[2] =~ /No such key: /
          return result[2]
        end
        
        # This is handled in providers/group.rb by Etc.getgrnam()
        # def group_exists?(group)
        #   groups = safe_dscl("list /Groups")
        #   !! ( groups =~ Regexp.new("\n#{group}\n") )
        # end

        # get a free GID greater than 200
        def get_free_gid(search_limit=1000)
          gid = nil; next_gid_guess = 200
          groups_gids = safe_dscl("list /Groups gid")
          while(next_gid_guess < search_limit + 200)
            if groups_gids =~ Regexp.new("#{Regexp.escape(next_gid_guess.to_s)}\n")
              next_gid_guess += 1
            else
              gid = next_gid_guess
              break
            end
          end
          return gid || raise("gid not found. Exhausted. Searched #{search_limit} times")
        end

        def gid_used?(gid)
          return false unless gid
          groups_gids = safe_dscl("list /Groups gid")
          !! ( groups_gids =~ Regexp.new("#{Regexp.escape(gid.to_s)}\n") )
        end

        def set_gid
          @new_resource.gid(get_free_gid) if [nil,""].include? @new_resource.gid
          raise(Chef::Exceptions::Group,"gid is already in use") if gid_used?(@new_resource.gid)
          safe_dscl("create /Groups/#{@new_resource.group_name} PrimaryGroupID #{@new_resource.gid}")
        end

        def set_members
          unless @new_resource.append
            Chef::Log.debug("#{@new_resource}: removing group members #{@current_resource.members.join(' ')}") unless @current_resource.members.empty?
            safe_dscl("create /Groups/#{@new_resource.group_name} GroupMembers ''") # clear guid list
            safe_dscl("create /Groups/#{@new_resource.group_name} GroupMembership ''") # clear user list
          end
          unless @new_resource.members.empty?
            Chef::Log.debug("#{@new_resource}: setting group members #{@new_resource.members.join(', ')}")
            safe_dscl("append /Groups/#{@new_resource.group_name} GroupMembership #{@new_resource.members.join(' ')}")
          end
        end

        def load_current_resource
          super
          raise Chef::Exceptions::Group, "Could not find binary /usr/bin/dscl for #{@new_resource}" unless ::File.exists?("/usr/bin/dscl")
        end
        
        def create_group
          dscl_create_group
          set_gid
          set_members
        end
        
        def manage_group
          if @new_resource.group_name && (@current_resource.group_name != @new_resource.group_name)
            dscl_create_group
          end
          if @new_resource.gid && (@current_resource.gid != @new_resource.gid)
            set_gid
          end
          if @new_resource.members && (@current_resource.members != @new_resource.members)
            set_members
          end
        end
        
        def dscl_create_group
          safe_dscl("create /Groups/#{@new_resource.group_name}")
          safe_dscl("create /Groups/#{@new_resource.group_name} Password '*'")
        end
        
        def remove_group
          safe_dscl("delete /Groups/#{@new_resource.group_name}")
        end
      end
    end
  end
end
