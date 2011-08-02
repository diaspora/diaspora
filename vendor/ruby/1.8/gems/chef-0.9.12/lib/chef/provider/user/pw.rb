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

require 'chef/provider/user'

class Chef
  class Provider
    class User
      class Pw < Chef::Provider::User

        def load_current_resource
          super
          raise Chef::Exceptions::User, "Could not find binary /usr/sbin/pw for #{@new_resource}" unless ::File.exists?("/usr/sbin/pw")
        end

        def create_user
          command = "pw useradd"
          command << set_options
          run_command(:command => command)
          modify_password
        end
        
        def manage_user
          command = "pw usermod"
          command << set_options
          run_command(:command => command)
          modify_password
        end
        
        def remove_user
          command = "pw userdel #{@new_resource.username}"
          command << " -r" if @new_resource.supports[:manage_home]
          run_command(:command => command)
        end
        
        def check_lock
          case @current_resource.password
          when /^\*LOCKED\*/
            @locked = true
          else
            @locked = false
          end
          @locked
        end
        
        def lock_user
          run_command(:command => "pw lock #{@new_resource.username}")
        end
        
        def unlock_user
          run_command(:command => "pw unlock #{@new_resource.username}")
        end
        
        def set_options
          opts = " #{@new_resource.username}"
          
          field_list = {
            'comment' => "-c",
            'home' => "-d",
            'gid' => "-g",
            'uid' => "-u",
            'shell' => "-s"
          }
          field_list.sort{ |a,b| a[0] <=> b[0] }.each do |field, option|
            field_symbol = field.to_sym
            if @current_resource.send(field_symbol) != @new_resource.send(field_symbol)
              if @new_resource.send(field_symbol)
                Chef::Log.debug("Setting #{@new_resource} #{field} to #{@new_resource.send(field_symbol)}")
                opts << " #{option} '#{@new_resource.send(field_symbol)}'"
              end
            end
          end
          if @new_resource.supports[:manage_home]
            Chef::Log.debug("Managing the home directory for #{@new_resource}")
            opts << " -m"
          end
          opts
        end
      
        def modify_password
          if @current_resource.password != @new_resource.password
            Chef::Log.debug("#{new_resource}: updating password")
            command = "pw usermod #{@new_resource.username} -H 0"
            status = popen4(command, :waitlast => true) do |pid, stdin, stdout, stderr|
              stdin.puts "#{@new_resource.password}"
            end
            
            unless status.exitstatus == 0
              raise Chef::Exceptions::User, "pw failed - #{status.inspect}!"
            end
          else
            Chef::Log.debug("#{new_resource}: no change needed to password")
          end
        end
      end
    end
  end
end