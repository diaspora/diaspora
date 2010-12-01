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

require 'chef/resource'

class Chef
  class Resource
    class File < Chef::Resource
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :file
        @path = name
        @backup = 5
        @action = "create"
        @allowed_actions.push(:create, :delete, :touch, :create_if_missing)
      end

      def content(arg=nil)
        set_or_return(
          :content,
          arg,
          :kind_of => String
        )
      end

      def backup(arg=nil)
        set_or_return(
          :backup,
          arg,
          :kind_of => [ Integer, FalseClass ]
        )
      end

      def checksum(arg=nil)
        set_or_return(
          :checksum,
          arg,
          :regex => /^[a-zA-Z0-9]{64}$/
        )
      end

      def group(arg=nil)
        set_or_return(
          :group,
          arg,
          :regex => Chef::Config[:group_valid_regex]
        )
      end

      def mode(arg=nil)
        set_or_return(
          :mode,
          arg,
          :regex => /^0?\d{3,4}$/
        )
      end

      def owner(arg=nil)
        set_or_return(
          :owner,
          arg,
          :regex => Chef::Config[:user_valid_regex]
        )
      end

      def path(arg=nil)
        set_or_return(
          :path,
          arg,
          :kind_of => String
        )
      end

    end
  end
end
