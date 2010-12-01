#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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
    class Ec2ServerList < Knife

      banner "knife ec2 server list [RUN LIST...] (options)"

      option :aws_access_key_id,
        :short => "-A ID",
        :long => "--aws-access-key-id KEY",
        :description => "Your AWS Access Key ID",
        :proc => Proc.new { |key| Chef::Config[:knife][:aws_access_key_id] = key } 

      option :aws_secret_access_key,
        :short => "-K SECRET",
        :long => "--aws-secret-access-key SECRET",
        :description => "Your AWS API Secret Access Key",
        :proc => Proc.new { |key| Chef::Config[:knife][:aws_secret_access_key] = key } 

      option :region,
        :long => "--region REGION",
        :description => "Your AWS region",
        :default => "us-east-1"

      def h
        @highline ||= HighLine.new
      end

      def run 
        require 'fog'
        require 'highline'
        require 'net/ssh/multi'
        require 'readline'

        $stdout.sync = true

        connection = Fog::AWS::EC2.new(
          :aws_access_key_id => Chef::Config[:knife][:aws_access_key_id],
          :aws_secret_access_key => Chef::Config[:knife][:aws_secret_access_key],
          :region => config[:region]
        )

        server_list = [ 
          h.color('Instance ID', :bold), 
          h.color('Public IP', :bold), 
          h.color('Private IP', :bold),
          h.color('Flavor', :bold),
          h.color('Image', :bold),
          h.color('Security Groups', :bold),
          h.color('State', :bold)
        ]
        connection.servers.all.each do |server|
          server_list << server.id.to_s
          server_list << (server.ip_address == nil ? "" : server.ip_address)
          server_list << (server.private_ip_address == nil ? "" : server.private_ip_address) 
          server_list << (server.flavor_id == nil ? "" : server.flavor_id)
          server_list << (server.image_id == nil ? "" : server.image_id)
          server_list << server.groups.join(", ")
          server_list << server.state
        end
        puts h.list(server_list, :columns_across, 7)

      end
    end
  end
end


