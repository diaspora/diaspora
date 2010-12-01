#
# Author:: Ian Meyer (<ianmmeyer@gmail.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

require 'chef/knife'
require 'json'

class Chef
  class Knife
    class SlicehostServerDelete < Knife

      banner "knife slicehost server delete SLICENAME"

      def run 
        require 'fog'
        require 'readline'
        
        slicehost = Fog::Slicehost.new(
          :slicehost_password => Chef::Config[:knife][:slicehost_password]
        )
      
        # Build hash of slice => id  
        servers = slicehost.servers.inject({}) { |h,f| h[f.name] = f.id; h }

        unless servers.has_key?(@name_args[0])
          Chef::Log.warn("I can't find a slice named #{@name_args[0]}")
          return false
        end
 
        confirm("Do you really want to delete server ID #{servers[@name_args[0]]} named #{@name_args[0]}")

        begin
          response = slicehost.delete_slice(servers[@name_args[0]])
          
          if response.headers['status'] == "200 OK" 
            Chef::Log.warn("Deleted server #{servers[@name_args[0]]} named #{@name_args[0]}")
          end
        rescue Excon::Errors::UnprocessableEntity
          Chef::Log.warn("There was a problem deleting #{@name_args[0]}, check your slice manager")
        end
      end
    end
  end
end



