#
# Author:: Jan Zimmek (<jan.zimmek@web.de>)
# Copyright:: Copyright (c) 2010 Jan Zimmek
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

require 'chef/provider/service/init'
require 'chef/mixin/command'

class Chef::Provider::Service::Arch < Chef::Provider::Service::Init
  
  def initialize(new_resource, run_context)
    super
    @init_command = "/etc/rc.d/#{@new_resource.service_name}"
  end
  
  def load_current_resource
  
    raise Chef::Exceptions::Service unless ::File.exists?("/etc/rc.conf")
    raise Chef::Exceptions::Service unless ::File.read("/etc/rc.conf").match(/DAEMONS=\((.*)\)/)

    super

    @current_resource.enabled(daemons.include?(@current_resource.service_name))

    @current_resource
  end

  def daemons
    entries = []
    if ::File.read("/etc/rc.conf").match(/DAEMONS=\((.*)\)/)
      entries += $1.split(" ") if $1.length > 0
    end
    
    yield(entries) if block_given?
    
    entries
  end
  
  def update_daemons(entries)
    content = ::File.read("/etc/rc.conf").gsub(/DAEMONS=\((.*)\)/, "DAEMONS=(#{entries.join(' ')})")
    ::File.open("/etc/rc.conf", "w") do |f|
      f.write(content)
    end
  end
  
  def enable_service()
    new_daemons = []
    entries = daemons
    
    if entries.include?(new_resource.service_name)
      # exists and already enabled
      new_daemons += entries
    else
      if entries.include?("!#{new_resource.service_name}")
        # exists but disabled
        entries.each do |daemon|
          if daemon == "!#{new_resource.service_name}"  
            new_daemons << new_resource.service_name
          else                                          
            new_daemons << daemon
          end
        end
      else
        # does not exist
        new_daemons += entries
        new_daemons << new_resource.service_name
      end
    end
    
    update_daemons(new_daemons)
  end
  
  def disable_service()
    new_daemons = []
    entries = daemons
    
    if entries.include?("!#{new_resource.service_name}")
      # exists and disabled
      new_daemons += entries
    else
      if entries.include?(new_resource.service_name)
        # exists but enabled
        entries.each do |daemon|
          if daemon == new_resource.service_name  
            new_daemons << "!#{new_resource.service_name}"
          else                                    
            new_daemons << daemon
          end
        end
      end
    end
    
    update_daemons(new_daemons)
  end

end
