#
# Author:: Ezra Zygmuntowicz (<ezra@engineyard.com>)
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
      class Portage < Chef::Provider::Package
      
        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)

          category = @new_resource.package_name.split('/').first
          pkg = @new_resource.package_name.split('/').last

          @current_resource.version(nil)

          catdir = "/var/db/pkg/#{category}"

          if( ::File.exists?(catdir) )
            Dir.entries(catdir).each do |entry|
              if(entry =~ /^#{Regexp.escape(pkg)}\-(\d[\.\d]*((_(alpha|beta|pre|rc|p)\d*)*)?(-r\d+)?)/)
                @current_resource.version($1)
                Chef::Log.debug("Got current version #{$1}")
                break
              end
            end
          end

          @current_resource
        end
      
      
        def parse_emerge(package, txt)
          available, installed, pkg = nil
          txt.each do |line|
            if line =~ /\*(.*)/
              pkg = $1.strip
            end
            if (pkg == package) || (pkg.split('/').last == package rescue false)
              if line =~ /Latest version available: (.*)/
                available = $1
              elsif line =~ /Latest version installed: (.*)/
                installed = $1
              end  
            end
          end  
          available = installed unless available
          [available, installed]
        end

        def candidate_version
          return @candidate_version if @candidate_version

          status = popen4("emerge --color n --nospinner --search #{@new_resource.package_name.split('/').last}") do |pid, stdin, stdout, stderr|
            available, installed = parse_emerge(@new_resource.package_name, stdout.read)
            @candidate_version = available
          end

          unless status.exitstatus == 0
            raise Chef::Exceptions::Package, "emerge --search failed - #{status.inspect}!"
          end

          @candidate_version

        end
        
        
        def install_package(name, version)
          pkg = "=#{name}-#{version}" 
          
          if(version =~ /^\~(.+)/)
            # If we start with a tilde
            pkg = "~#{name}-#{$1}"
          end
     
          run_command_with_systems_locale(
            :command => "emerge -g --color n --nospinner --quiet#{expand_options(@new_resource.options)} #{pkg}"
          )
        end
      
        def upgrade_package(name, version)
          install_package(name, version)
        end
      
        def remove_package(name, version)
          if(version)
            pkg = "=#{@new_resource.package_name}-#{version}"
          else            
            pkg = "#{@new_resource.package_name}"
          end

          run_command_with_systems_locale(
            :command => "emerge --unmerge --color n --nospinner --quiet#{expand_options(@new_resource.options)} #{pkg}"
          )
        end
      
        def purge_package(name, version)
          remove_package(name, version)
        end
      
      end
    end
  end
end
