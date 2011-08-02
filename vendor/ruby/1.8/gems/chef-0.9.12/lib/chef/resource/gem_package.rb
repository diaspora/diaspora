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

require 'chef/resource/package'

class Chef
  class Resource
    class GemPackage < Chef::Resource::Package
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :gem_package
        @provider = Chef::Provider::Package::Rubygems
      end

      # Sets a custom gem_binary to run for gem commands.
      def gem_binary(gem_cmd=nil)
        set_or_return(:gem_binary,gem_cmd,:kind_of => [ String ])
      end

      ##
      # Options for the gem install, either a Hash or a String. When a hash is
      # given, the options are passed to Gem::DependencyInstaller.new, and the
      # gem will be installed via the gems API. When a String is given, the gem
      # will be installed by shelling out to the gem command. Using a Hash of
      # options with an explicit gem_binary will result in undefined behavior.
      def options(opts=nil)
        set_or_return(:options,opts,:kind_of => [String,Hash])
      end


    end
  end
end
