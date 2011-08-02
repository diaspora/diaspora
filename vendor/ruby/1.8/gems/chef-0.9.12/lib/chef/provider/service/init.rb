#
# Author:: AJ Christensen (<aj@hjksolutions.com>)
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

require 'chef/provider/service'
require 'chef/provider/service/simple'
require 'chef/mixin/command'

class Chef
  class Provider
    class Service
      class Init < Chef::Provider::Service::Simple
        
        def initialize(new_resource, run_context)
          super
          @init_command = "/etc/init.d/#{@new_resource.service_name}"
        end

        def start_service
          if @new_resource.start_command
            super
          else
            run_command(:command => "#{@init_command} start")
          end
        end

        def stop_service
          if @new_resource.stop_command
            super
          else
            run_command(:command => "#{@init_command} stop")
          end
        end

        def restart_service
          if @new_resource.restart_command
            super
          elsif @new_resource.supports[:restart]
            run_command(:command => "#{@init_command} restart")
          else
            stop_service
            sleep 1
            start_service
          end
        end

        def reload_service
          if @new_resource.reload_command
            super
          elsif @new_resource.supports[:reload]
            run_command(:command => "#{@init_command} reload")
          end
        end
      end
    end
  end
end
