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
    class SlicehostServerList < Knife

      banner "knife slicehost server list (options)"

      def h
        @highline ||= HighLine.new
      end

      def run 
        require 'fog'
        require 'highline'
        require 'net/ssh/multi'
        require 'readline'
        
        slicehost = Fog::Slicehost.new(
          :slicehost_password => Chef::Config[:knife][:slicehost_password]
        )
       
        # Make hash of flavor id => name and image id => name
        flavors = slicehost.flavors.inject({}) { |h,f| h[f.id] = f.name; h }
        images  = slicehost.images.inject({}) { |h,i| h[i.id] = i.name; h }
 
        server_list = [ h.color('ID', :bold), h.color('Name', :bold), h.color('Public IP', :bold), h.color('Private IP', :bold), h.color('Image', :bold), h.color('Flavor', :bold) ]
 
        slicehost.servers.each do |server|
          server_list << server.id.to_s
          server_list << server.name
          server_list << server.addresses[1]
          server_list << server.addresses[0]
          server_list << images[server.image_id].to_s
          server_list << flavors[server.flavor_id].to_s
        end
        puts h.list(server_list, :columns_across, 6)

      end
    end
  end
end



