#
# Author:: Lee Jensen (<ljensen@engineyard.com>)
# Author:: AJ Christensen (<aj@opscode.com>)
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
require 'chef/mixin/command'

class Chef::Provider::Service::Gentoo < Chef::Provider::Service::Init
  def load_current_resource

    @new_resource.supports[:status] = true
    @new_resource.supports[:restart] = true

    super
    
    raise Chef::Exceptions::Service unless ::File.exists?("/sbin/rc-update")
    
    Chef::Log.debug "#{@new_resource}: checking service enable state"
    @current_resource.enabled(
      Dir.glob("/etc/runlevels/**/#{@current_resource.service_name}").any? do |file|
        exists = ::File.exists? file
        readable = ::File.readable? file
        Chef::Log.debug "#{@new_resource}: exists: #{exists}, readable: #{readable}"
        exists and readable
      end
    )
    Chef::Log.debug "#{@new_resource}: enabled: #{@current_resource.enabled}"

    @current_resource
  end
  
  def enable_service()
    run_command(:command => "/sbin/rc-update add #{@new_resource.service_name} default")
  end
  
  def disable_service()
    run_command(:command => "/sbin/rc-update del #{@new_resource.service_name} default")
  end
end
