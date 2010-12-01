#
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Copyright:: Copyright (c) 2010 VMware, Inc.
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

class Chef
  class Resource
    class Env < Chef::Resource

      def initialize(name, run_context=nil)
        super
        @resource_name = :env
        @key_name = name
        @value = nil
        @action = :create
        @delim = nil
        @allowed_actions.push(:create, :delete, :modify)
      end

      def key_name(arg=nil)
        set_or_return(
          :key_name,
          arg,
          :kind_of => [ String ]
        )
      end

      def value(arg=nil)
        set_or_return(
          :value,
          arg,
          :kind_of => [ String ]
        )
      end

      def delim(arg=nil)
        set_or_return(
          :delim,
          arg,
          :kind_of => [ String ]
        )
      end
    end
  end
end
