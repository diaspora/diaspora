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
    class SlicehostServerCreate < Knife

      banner "knife slicehost server create [RUN LIST...] (options)"

      option :flavor,
        :short => "-f FLAVOR",
        :long => "--flavor FLAVOR",
        :description => "The flavor of server",
        :proc => Proc.new { |f| f.to_i },
        :default => 1

      option :image,
        :short => "-i IMAGE",
        :long => "--image IMAGE",
        :description => "The image of the server",
        :proc => Proc.new { |i| i.to_i },
        :default => 49

      option :server_name,
        :short => "-N NAME",
        :long => "--server-name NAME",
        :description => "The server name",
        :default => "wtf"

      option :slicehost_password,
        :short => "-K KEY",
        :long => "--slicehost-password password",
        :description => "Your slicehost API password",
        :proc => Proc.new { |password| Chef::Config[:knife][:slicehost_password] = password } 


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

        flavors = slicehost.flavors.inject({}) { |h,f| h[f.id] = f.name; h }
        images  = slicehost.images.inject({}) { |h,i| h[i.id] = i.name; h }

        response = slicehost.create_slice(config[:flavor],
                               config[:image],
                               config[:server_name])
        $stdout.sync = true

        puts "#{h.color("Name", :cyan)}: #{response.body['name']}"
        puts "#{h.color("Flavor", :cyan)}: #{flavors[response.body['flavor-id']]}"
        puts "#{h.color("Image", :cyan)}: #{images[response.body['image-id']]}"
        puts "#{h.color("Public Address", :cyan)}: #{response.body['addresses'][1]}"
        puts "#{h.color("Private Address", :cyan)}: #{response.body['addresses'][0]}"
        puts "#{h.color("Password", :cyan)}: #{response.body['root-password']}"
     
        print "\n#{h.color("Requesting status of #{response.body['name']}", :magenta)}"
        saved_password = response.body['root-password']

        # wait for it to be ready to do stuff
        loop do
          sleep 15
          host = slicehost.get_slice(response.body['id'])
          if host.body['status'] == 'active'
            break
          end
        end

        puts "\nServer ready!!"
      
      end
    end
  end
end


