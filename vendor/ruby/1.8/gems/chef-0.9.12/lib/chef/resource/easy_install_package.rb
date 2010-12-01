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

require 'chef/resource/package'

class Chef
  class Resource
    class EasyInstallPackage < Chef::Resource::Package
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :easy_install_package
        @provider = Chef::Provider::Package::EasyInstall
      end

      def easy_install_binary(arg=nil)
        set_or_return(
          :easy_install_binary,
          arg,
          :kind_of => [ String ]
        )
      end

    end
  end
end
