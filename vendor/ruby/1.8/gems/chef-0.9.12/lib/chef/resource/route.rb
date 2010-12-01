#
# Author:: Bryan McLellan (btm@loftninjas.org)
# Copyright:: Copyright (c) 2009 Bryan McLellan
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
    class Route < Chef::Resource
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :route
        @target = name
        @action = :add
        @allowed_actions.push(:add, :delete)
        @netmask = nil
        @gateway = nil
        @metric = nil
        @device = nil 
        @route_type = :host
        @networking = nil
        @networking_ipv6 = nil
        @hostname = nil
        @domainname = nil
        @domain = nil
      end

      def networking(arg=nil)
        set_or_return(
          :networking,
          arg,
          :kind_of => String
        )
      end

      def networking_ipv6(arg=nil)
        set_or_return(
          :networking_ipv6,
          arg,
          :kind_of => String
        )
      end

      def hostname(arg=nil)
        set_or_return(
          :hostname,
          arg,
          :kind_of => String
        )
      end

      def domainname(arg=nil)
        set_or_return(
          :domainname,
          arg,
          :kind_of => String
        )
      end

      def domain(arg=nil)
        set_or_return(
          :domain,
          arg,
          :kind_of => String
        )
      end

      def target(arg=nil)
        set_or_return(
          :target,
          arg,
          :kind_of => String
        )
      end

      def netmask(arg=nil)
        set_or_return(
          :netmask,
          arg,
          :kind_of => String
        )
      end

      def gateway(arg=nil)
        set_or_return(
          :gateway,
          arg,
          :kind_of => String
        )
      end

      def metric(arg=nil)
        set_or_return(
          :metric,
          arg,
          :kind_of => Integer
        )
      end

      def device(arg=nil)
        set_or_return(
          :device,
          arg,
          :kind_of => String
        )
      end

      def route_type(arg=nil)
        real_arg = arg.kind_of?(String) ? arg.to_sym : arg
        set_or_return(
          :route_type,
          real_arg,
          :equal_to => [ :host, :net ]
        )
      end
    end
  end
end


