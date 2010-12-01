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

require 'chef/provider/package'
require 'chef/mixin/command'
require 'chef/resource/package'

class Chef
  class Provider
    class Package
      class Apt < Chef::Provider::Package  
      
        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
        
          Chef::Log.debug("Checking apt-cache policy for #{@new_resource.package_name}")
          status = popen4("apt-cache policy #{@new_resource.package_name}") do |pid, stdin, stdout, stderr|
            stdout.each do |line|
              case line
              when /^\s{2}Installed: (.+)$/
                installed_version = $1
                if installed_version == '(none)'
                  Chef::Log.debug("Current version is nil")
                  @current_resource.version(nil)
                else
                  Chef::Log.debug("Current version is #{installed_version}")
                  @current_resource.version(installed_version)
                end
              when /^\s{2}Candidate: (.+)$/
                Chef::Log.debug("Current version is #{$1}")                
                @candidate_version = $1
              end
            end
          end

          unless status.exitstatus == 0
            raise Chef::Exceptions::Package, "apt-cache failed - #{status.inspect}!"
          end
          
          if @candidate_version == "(none)"
            raise Chef::Exceptions::Package, "apt does not have a version of package #{@new_resource.package_name}"
          end
        
          @current_resource
        end
      
        def install_package(name, version)
          run_command_with_systems_locale(
            :command => "apt-get -q -y#{expand_options(@new_resource.options)} install #{name}=#{version}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end
      
        def upgrade_package(name, version)
          install_package(name, version)
        end
      
        def remove_package(name, version)
          run_command_with_systems_locale(
            :command => "apt-get -q -y#{expand_options(@new_resource.options)} remove #{@new_resource.package_name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end
      
        def purge_package(name, version)
          run_command_with_systems_locale(
            :command => "apt-get -q -y#{expand_options(@new_resource.options)} purge #{@new_resource.package_name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end
        
        def preseed_package(name, version)
          preseed_file = get_preseed_file(name, version)
          if preseed_file
            Chef::Log.info("Pre-seeding #{@new_resource} with package installation instructions.")
            run_command_with_systems_locale(
              :command => "debconf-set-selections #{preseed_file}",
              :environment => {
                "DEBIAN_FRONTEND" => "noninteractive"
              }
            )
          end
        end
      
      end
    end
  end
end
