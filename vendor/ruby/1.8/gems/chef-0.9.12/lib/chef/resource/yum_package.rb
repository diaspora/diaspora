#
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

require 'chef/resource/package'
require 'chef/provider/package/yum'

class Chef
  class Resource
    class YumPackage < Chef::Resource::Package

      def initialize(name, run_context=nil)
        super
        @resource_name = :yum_package
        @provider = Chef::Provider::Package::Yum
      end

      # Install a specific arch
      def arch(arg=nil)
        set_or_return(
          :arch,
          arg,
          :kind_of => [ String ]
        )
      end

    end
  end
end
