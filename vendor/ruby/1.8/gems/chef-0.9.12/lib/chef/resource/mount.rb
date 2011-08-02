#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc
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
    class Mount < Chef::Resource
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :mount
        @mount_point = name
        @device = nil
        @device_type = :device
        @fstype = "auto"
        @options = ["defaults"]
        @dump = 0
        @pass = 2
        @mounted = false
        @enabled = false
        @action = :mount
        @supports = { :remount => false }
        @allowed_actions.push(:mount, :umount, :remount, :enable, :disable)
      end
      
      def mount_point(arg=nil)
        set_or_return(
          :mount_point,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def device(arg=nil)
        set_or_return(
          :device,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def device_type(arg=nil)
        real_arg = arg.kind_of?(String) ? arg.to_sym : arg
        set_or_return(
          :device_type,
          real_arg,
          :equal_to => [ :device, :label, :uuid ]
        )
      end

      def fstype(arg=nil)
        set_or_return(
          :fstype,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def options(arg=nil)
        if arg.is_a?(String)
          arg.gsub!(/,/, ' ')
          converted_arg = arg.split(/ /)
        else
          converted_arg = arg
        end
        set_or_return(
          :options,
          converted_arg,
          :kind_of => [ Array ]
        )
      end
      
      def dump(arg=nil)
        set_or_return(
          :dump,
          arg,
          :kind_of => [ Integer, FalseClass ]
        )
      end
      
      def pass(arg=nil)
        set_or_return(
          :pass,
          arg,
          :kind_of => [ Integer, FalseClass ]
        )
      end
      
      def mounted(arg=nil)
        set_or_return(
          :mounted,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

      def enabled(arg=nil)
        set_or_return(
          :enabled,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end
        
      def supports(args={})
        if args.is_a? Array
          args.each { |arg| @supports[arg] = true }
        elsif args.any?
          @supports = args
        else
          @supports
        end
      end
      
    end
  end
end

        
