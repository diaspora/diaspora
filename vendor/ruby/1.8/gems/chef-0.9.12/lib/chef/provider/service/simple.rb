#
# Author:: Mathieu Sauve-Frankel <msf@kisoku.net>
# Copyright:: Copyright (c) 2009 Mathieu Sauve-Frankel
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

require 'chef/provider/service'
require 'chef/mixin/command'

class Chef
  class Provider
    class Service
      class Simple < Chef::Provider::Service
        def load_current_resource
          @current_resource = Chef::Resource::Service.new(@new_resource.name)
          @current_resource.service_name(@new_resource.service_name)
          if @new_resource.status_command
            Chef::Log.debug("#{@new_resource} you have specified a status command, running..")

            begin
              if run_command(:command => @new_resource.status_command) == 0
                @current_resource.running true
              end
            rescue Chef::Exceptions::Exec
              @current_resource.running false
              nil
            end

          elsif @new_resource.supports[:status]
            Chef::Log.debug("#{@new_resource} supports status, running")

            begin
              if run_command(:command => "#{@init_command} status") == 0
                @current_resource.running true
              end
            rescue Chef::Exceptions::Exec
              @current_resource.running false
              nil
            end
          elsif
            Chef::Log.debug "#{@new_resource}: falling back to process table inspection"
            if ps_cmd.nil? or ps_cmd.empty?
              raise Chef::Exceptions::Service, "#{@new_resource}: could not determine how to inspect the process table, please set this nodes 'command.ps' attribute"
            end
            status = popen4(ps_cmd) do |pid, stdin, stdout, stderr|
              r = Regexp.new(@new_resource.pattern)
              Chef::Log.debug "#{@new_resource}: attempting to match '#{@new_resource.pattern}' (#{r.inspect}) against process list"
              stdout.each_line do |line|
                if r.match(line)
                  @current_resource.running true
                  break
                end
              end
              @current_resource.running false unless @current_resource.running
            end
            unless status.exitstatus == 0
              raise Chef::Exceptions::Service, "Command #{ps_cmd} failed"
            else
              Chef::Log.debug "#{@new_resource}: running: #{@current_resource.running}"
            end
          end

          @current_resource
        end

        def start_service
          if @new_resource.start_command
            run_command(:command => @new_resource.start_command)
          else
            raise Chef::Exceptions::Service, "#{self.to_s} requires that start_command to be set"
          end
        end

        def stop_service
          if @new_resource.stop_command
            run_command(:command => @new_resource.stop_command)
          else
            raise Chef::Exceptions::Service, "#{self.to_s} requires that stop_command to be set"
          end
        end

        def restart_service
          if @new_resource.restart_command
            run_command(:command => @new_resource.restart_command)
          else
            stop_service
            sleep 1
            start_service
          end
        end

        def reload_service
          if @new_resource.reload_command
            run_command(:command => @new_resource.reload_command)
          else
            raise Chef::Exceptions::Service, "#{self.to_s} requires that reload_command to be set"
          end
        end
        
        def ps_cmd
          @run_context.node[:command] && @run_context.node[:command][:ps]
        end
      end
    end
  end
end
