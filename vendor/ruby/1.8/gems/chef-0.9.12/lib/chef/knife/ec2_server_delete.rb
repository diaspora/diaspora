#
# Author:: Adam Jacob (<adam@opscode.com>)
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
    class Ec2ServerDelete < Knife

      banner "knife ec2 server delete SERVER [SERVER] (options)"
      
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

        connection = Fog::AWS::EC2.new(
          :aws_access_key_id => Chef::Config[:knife][:aws_access_key_id],
          :aws_secret_access_key => Chef::Config[:knife][:aws_secret_access_key],
          :region => config[:region]
        )

        @name_args.each do |instance_id|
          server = connection.servers.get(instance_id)

          puts "#{h.color("Instance ID", :cyan)}: #{server.id}"
          puts "#{h.color("Flavor", :cyan)}: #{server.flavor_id}"
          puts "#{h.color("Image", :cyan)}: #{server.image_id}"
          puts "#{h.color("Availability Zone", :cyan)}: #{server.availability_zone}"
          puts "#{h.color("Security Groups", :cyan)}: #{server.groups.join(", ")}"
          puts "#{h.color("SSH Key", :cyan)}: #{server.key_name}"
          puts "#{h.color("Public DNS Name", :cyan)}: #{server.dns_name}"
          puts "#{h.color("Public IP Address", :cyan)}: #{server.ip_address}"
          puts "#{h.color("Private DNS Name", :cyan)}: #{server.private_dns_name}"
          puts "#{h.color("Private IP Address", :cyan)}: #{server.private_ip_address}"

          puts "\n"
          confirm("Do you really want to delete this server")

          server.destroy

          Chef::Log.warn("Deleted server #{server.id}")
        end
      end
    end
  end
end





