#
# Author:: Bryan McLellan (btm@loftninjas.org)
# Copyright:: Copyright (c) 2009 Bryan McLellan
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
      class Dpkg < Chef::Provider::Package::Apt
        DPKG_INFO = /([a-z\d\-\+]+)\t([\w\d.-]+)/
        DPKG_INSTALLED = /^Status: install ok installed/
        DPKG_VERSION = /^Version: (.+)$/
      
        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @new_resource.version(nil)

          # if the source was not set, and we're installing, fail
          if Array(@new_resource.action).include?(:install) && @new_resource.source.nil?
            raise Chef::Exceptions::Package, "Source for package #{@new_resource.name} required for action install"
          end

          # We only -need- source for action install
          if @new_resource.source
            unless ::File.exists?(@new_resource.source)
              raise Chef::Exceptions::Package, "Package #{@new_resource.name} not found: #{@new_resource.source}"
            end

            # Get information from the package if supplied
            Chef::Log.debug("Checking dpkg status for #{@new_resource.package_name}")
            status = popen4("dpkg-deb -W #{@new_resource.source}") do |pid, stdin, stdout, stderr|
              stdout.each_line do |line|
                if pkginfo = DPKG_INFO.match(line)
                  @current_resource.package_name(pkginfo[1])
                  @new_resource.version(pkginfo[2])
                end
              end
            end
          end
          
          # Check to see if it is installed
          package_installed = nil
          Chef::Log.debug("Checking install state for #{@current_resource.package_name}")
          status = popen4("dpkg -s #{@current_resource.package_name}") do |pid, stdin, stdout, stderr|
            stdout.each_line do |line|
              case line
              when DPKG_INSTALLED
                package_installed = true
              when DPKG_VERSION
                if package_installed
                  Chef::Log.debug("Current version is #{$1}")                
                  @current_resource.version($1)
                end
              end
            end
          end

          unless status.exitstatus == 0 || status.exitstatus == 1
            raise Chef::Exceptions::Package, "dpkg failed - #{status.inspect}!"
          end
          
          @current_resource
        end
     
        def install_package(name, version)
          run_command_with_systems_locale(
            :command => "dpkg -i#{expand_options(@new_resource.options)} #{@new_resource.source}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end

        def remove_package(name, version)
          run_command_with_systems_locale(
            :command => "dpkg -r#{expand_options(@new_resource.options)} #{@new_resource.package_name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end
      
        def purge_package(name, version)
          run_command_with_systems_locale(
            :command => "dpkg -P#{expand_options(@new_resource.options)} #{@new_resource.package_name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end
      end
    end
  end
end
