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

require 'chef/resource'

class Chef
  class Resource
    class Mdadm < Chef::Resource
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :mdadm

        @chunk = 16
        @devices = []
        @exists = false
        @level = 1
        @raid_device = name

        @action = :create
        @allowed_actions.push(:create, :assemble, :stop)
      end

      def chunk(arg=nil)
        set_or_return(
          :chunk,
          arg,
          :kind_of => [ Integer ]
        )
      end

      def devices(arg=nil)
        set_or_return(
          :devices,
          arg,
          :kind_of => [ Array ]
        )
      end

      def exists(arg=nil)
        set_or_return(
          :exists,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

      def level(arg=nil)
        set_or_return(
          :level,
          arg,
          :kind_of => [ Integer ]
        )
      end

      def raid_device(arg=nil)
        set_or_return(
          :raid_device,
          arg,
          :kind_of => [ String ]
        )
      end


    end
  end
end
