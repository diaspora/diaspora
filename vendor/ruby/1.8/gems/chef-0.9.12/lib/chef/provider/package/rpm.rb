#
# Author:: Joshua Timberman (<joshua@opscode.com>)
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
require 'chef/provider/package'
require 'chef/mixin/command'
require 'chef/resource/package'

class Chef
  class Provider
    class Package
      class Rpm < Chef::Provider::Package
        
        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @new_resource.version(nil)
          
          if @new_resource.source
            unless ::File.exists?(@new_resource.source)
              raise Chef::Exceptions::Package, "Package #{@new_resource.name} not found: #{@new_resource.source}"
            end
            
            Chef::Log.debug("Checking rpm status for #{@new_resource.package_name}")
            status = popen4("rpm -qp --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' #{@new_resource.source}") do |pid, stdin, stdout, stderr|
              stdout.each do |line|
                case line
                when /([\w\d_.-]+)\s([\w\d_.-]+)/
                  @current_resource.package_name($1)
                  @new_resource.version($2)
                end
              end
            end
          else
            if Array(@new_resource.action).include?(:install)
              raise Chef::Exceptions::Package, "Source for package #{@new_resource.name} required for action install"
            end
          end
          
          Chef::Log.debug("Checking install state for #{@current_resource.package_name}")
          status = popen4("rpm -q --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' #{@current_resource.package_name}") do |pid, stdin, stdout, stderr|
            stdout.each do |line|
              case line
              when /([\w\d_.-]+)\s([\w\d_.-]+)/
                Chef::Log.debug("Current version is #{$2}")
                @current_resource.version($2)
              end
            end
          end
          
          unless status.exitstatus == 0 || status.exitstatus == 1
            raise Chef::Exceptions::Package, "rpm failed - #{status.inspect}!"
          end
          
          @current_resource
        end
        
        def install_package(name, version)
          unless @current_resource.version
            run_command_with_systems_locale(
              :command => "rpm #{@new_resource.options} -i #{@new_resource.source}"
            )
          else
            run_command_with_systems_locale(
              :command => "rpm #{@new_resource.options} -U #{@new_resource.source}"
            )
          end
        end
        
        alias_method :upgrade_package, :install_package
        
        def remove_package(name, version)
          if version
            run_command_with_systems_locale(
              :command => "rpm #{@new_resource.options} -e #{name}-#{version}"
            )
          else
            run_command_with_systems_locale(
              :command => "rpm #{@new_resource.options} -e #{name}"
            )
          end
        end

      end
    end
  end
end

