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
require 'chef/provider/service/init'
require 'chef/mixin/shell_out'

class Chef
  class Provider
    class Service
      class Redhat < Chef::Provider::Service::Init
        include Chef::Mixin::ShellOut
        
        CHKCONFIG_ON = /\d:on/
        
        def initialize(new_resource, run_context)
          super
           @init_command = "/sbin/service #{@new_resource.service_name}"
           @new_resource.supports[:status] = true
         end
        
        def load_current_resource
          unless ::File.exists? "/sbin/chkconfig"
            raise Chef::Exceptions::Service, "/sbin/chkconfig does not exist!"
          end
          
          super
          
          chkconfig = shell_out!("/sbin/chkconfig --list #{@current_resource.service_name}", :returns => [0,1])
          @current_resource.enabled(!!(chkconfig.stdout =~ CHKCONFIG_ON))
          @current_resource        
        end

        def enable_service()
          shell_out! "/sbin/chkconfig #{@new_resource.service_name} on"
        end

        def disable_service()
          shell_out! "/sbin/chkconfig #{@new_resource.service_name} off"
        end
        
      end
    end
  end
end
