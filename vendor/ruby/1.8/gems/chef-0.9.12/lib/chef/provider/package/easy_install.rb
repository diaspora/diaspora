#
# Author:: Joe Williams (<joe@joetify.com>)
# Copyright:: Copyright (c) 2009 Joe Williams
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
require 'chef/mixin/shell_out'
require 'chef/resource/package'
require 'chef/mixin/shell_out'

class Chef
  class Provider
    class Package
      class EasyInstall < Chef::Provider::Package

        include Chef::Mixin::ShellOut

        def install_check(name)
          check = false

          begin
            # first check to see if we can import it
            output = shell_out!("python -c \"import #{name}\"").stderr
            unless output.include? "ImportError"
              check = true
            end
          rescue
            # then check to see if its on the path
            output = shell_out!("python -c \"import sys; print sys.path\"").stdout
            if output.downcase.include? "#{name.downcase}"
              check = true
            end
          end

          check
        end

        def easy_install_binary_path
          path = @new_resource.easy_install_binary
          path ? path : 'easy_install'
        end

        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @current_resource.version(nil)

          # get the currently installed version if installed
          package_version = nil
          if install_check(@new_resource.package_name)
            begin
              output = shell_out!("python -c \"import #{@new_resource.package_name}; print #{@new_resource.package_name}.__version__\"").stdout
              package_version = output.strip
            rescue
              output = shell_out!("python -c \"import #{@new_resource.package_name}; print #{@new_resource.package_name}.__path__\"").stdout
              output[/\S\S(.*)\/(.*)-(.*)-py(.*).egg\S/]
              package_version = $3
            end
          end

          if package_version == @new_resource.version
            Chef::Log.debug("#{@new_resource.package_name} at version #{@new_resource.version}")
          @current_resource.version(@new_resource.version)
          else
            Chef::Log.debug("#{@new_resource.package_name} at version #{package_version}")
            @current_resource.version(package_version)
          end

          @current_resource
        end

        def candidate_version
           return @candidate_version if @candidate_version

           # do a dry run to get the latest version
           result = shell_out!("#{easy_install_binary_path} -n #{@new_resource.package_name}", :returns=>[0,1])
           @candidate_version = result.stdout[/(.*)Best match: (.*) (.*)$/, 3]
           @candidate_version
        end

        def install_package(name, version)
          run_command(:command => "#{easy_install_binary_path} \"#{name}==#{version}\"")
        end

        def upgrade_package(name, version)
          install_package(name, version)
        end

        def remove_package(name, version)
          run_command(:command => "#{easy_install_binary_path} -m #{name}")
        end

        def purge_package(name, version)
          remove_package(name, version)
        end

      end
    end
  end
end