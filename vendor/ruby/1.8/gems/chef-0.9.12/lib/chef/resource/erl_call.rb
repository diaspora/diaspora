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
    class ErlCall < Chef::Resource

      # erl_call : http://erlang.org/doc/man/erl_call.html
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :erl_call

        @code = "q()." # your erlang code goes here
        @cookie = nil # cookie of the erlang node
        @distributed = false # if you want to have a distributed erlang node
        @name_type = "sname" # type of erlang hostname name or sname
        @node_name = "chef@localhost" # the erlang node hostname

        @action = "run"
        @allowed_actions.push(:run)
      end

      def code(arg=nil)
        set_or_return(
          :code,
          arg,
          :kind_of => [ String ]
        )
      end

      def cookie(arg=nil)
        set_or_return(
          :cookie,
          arg,
          :kind_of => [ String ]
        )
      end

      def distributed(arg=nil)
        set_or_return(
          :distributed,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

      def name_type(arg=nil)
        set_or_return(
          :name_type,
          arg,
          :kind_of => [ String ]
        )
      end

      def node_name(arg=nil)
        set_or_return(
          :node_name,
          arg,
          :kind_of => [ String ]
        )
      end

    end
  end
end
