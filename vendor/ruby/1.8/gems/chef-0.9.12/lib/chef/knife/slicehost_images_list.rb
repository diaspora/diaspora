#
# Author:: Ian Meyer (<ianmmeyer@gmail.com>)
# Copyright:: Copyright (c) 2010 Ian Meyer
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
    class SlicehostImagesList < Knife

      banner "knife slicehost images list"

      def highline
        @highline ||= HighLine.new
      end

      def run
        require 'fog'
        require 'highline'

        slicehost = Fog::Slicehost.new(
          :slicehost_password => Chef::Config[:knife][:slicehost_password]
        )

        images  = slicehost.images.inject({}) { |h,i| h[i.id] = i.name; h }

        image_list = [ highline.color('ID', :bold), highline.color('Name', :bold) ]

        slicehost.images.each do |server|
          image_list << server.id.to_s
          image_list << server.name
        end
        puts highline.list(image_list, :columns_across, 2)

      end
    end
  end
end
