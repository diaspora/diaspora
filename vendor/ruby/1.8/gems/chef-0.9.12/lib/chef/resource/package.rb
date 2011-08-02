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
    class Package < Chef::Resource
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :package
        @package_name = name
        @version = nil
        @candidate_version = nil
        @response_file = nil
        @source = nil
        @action = :install
        @options = nil
        @allowed_actions.push(:install, :upgrade, :remove, :purge)
      end
      
      def package_name(arg=nil)
        set_or_return(
          :package_name,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def version(arg=nil)
        set_or_return(
          :version,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def response_file(arg=nil)
        set_or_return(
          :response_file,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def source(arg=nil)
        set_or_return(
          :source,
          arg,
          :kind_of => [ String ]
        )
      end

      def options(arg=nil)
        set_or_return(
	  :options,
	  arg,
	  :kind_of => [ String ]
	)
      end

    end
  end
end
