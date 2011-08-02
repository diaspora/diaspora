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

require 'chef/provider/user'

class Chef
  class Provider
    class User 
      class Useradd < Chef::Provider::User
        UNIVERSAL_OPTIONS = [[:comment, "-c"], [:gid, "-g"], [:password, "-p"], [:shell, "-s"], [:uid, "-u"]]

        def create_user
          command = compile_command("useradd") do |useradd|
            useradd << universal_options
            useradd << useradd_options
          end
          run_command(:command => command)
        end
        
        def manage_user
          command = compile_command("usermod") { |u| u << universal_options }
          run_command(:command => command)
        end
        
        def remove_user
          command = "userdel"
          command << " -r" if managing_home_dir?
          command << " #{@new_resource.username}"
          run_command(:command => command)
        end
        
        def check_lock
          status = popen4("passwd -S #{@new_resource.username}") do |pid, stdin, stdout, stderr|
            status_line = stdout.gets.split(' ')
            case status_line[1]
            when /^P/
              @locked = false
            when /^N/
              @locked = false
            when /^L/
              @locked = true
            end
          end

          unless status.exitstatus == 0
            raise_lock_error = false
            # we can get an exit code of 1 even when it's successful on rhel/centos (redhat bug 578534)
            if status.exitstatus == 1 && ['redhat', 'centos'].include?(node[:platform])
              passwd_version_status = popen4('rpm -q passwd') do |pid, stdin, stdout, stderr|
                passwd_version = stdout.gets.chomp

                unless passwd_version == 'passwd-0.73-1'
                  raise_lock_error = true
                end
              end
            else
              raise_lock_error = true
            end

            raise Chef::Exceptions::User, "Cannot determine if #{@new_resource} is locked!" if raise_lock_error
          end

          @locked
        end
        
        def lock_user
          run_command(:command => "usermod -L #{@new_resource.username}")
        end
        
        def unlock_user
          run_command(:command => "usermod -U #{@new_resource.username}")
        end

        def compile_command(base_command)
          yield base_command
          base_command << " #{@new_resource.username}"
          base_command
        end
        
        def universal_options
          opts = ''
          
          UNIVERSAL_OPTIONS.each do |field, option|
            if @current_resource.send(field) != @new_resource.send(field)
              if @new_resource.send(field)
                Chef::Log.debug("Setting #{@new_resource} #{field} to #{@new_resource.send(field)}")
                opts << " #{option} '#{@new_resource.send(field)}'"
              end
            end
          end
          if updating_home?
            if managing_home_dir?
              Chef::Log.debug("Managing the home directory for #{@new_resource}")
              opts << " -d '#{@new_resource.home}'"
            else
              Chef::Log.debug("Setting #{@new_resource} home to #{@new_resource.home}")
              opts << " -d '#{@new_resource.home}'"
            end
          end
          opts << " -o" if @new_resource.non_unique || @new_resource.supports[:non_unique]
          opts
        end

        def useradd_options
          opts = ''
          opts << " -m" if updating_home? && managing_home_dir?
          opts << " -r" if @new_resource.system
          opts
        end

        def updating_home?
          @current_resource.home != @new_resource.home && @new_resource.home
        end

        def managing_home_dir?
          @new_resource.manage_home || @new_resource.supports[:manage_home]
        end

      end
    end
  end
end
