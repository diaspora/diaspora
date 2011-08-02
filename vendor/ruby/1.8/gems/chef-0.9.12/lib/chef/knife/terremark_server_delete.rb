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
    class TerremarkServerDelete < Knife

      banner "knife terremark server delete SERVER (options)"

      def h
        @highline ||= HighLine.new
      end

      def run 
        require 'fog'
        require 'highline'

        terremark = Fog::Terremark.new(
          :terremark_username => Chef::Config[:knife][:terremark_username],
          :terremark_password => Chef::Config[:knife][:terremark_password],
          :terremark_service  => Chef::Config[:knife][:terremark_service] || :vcloud
        )

        $stdout.sync = true

        vapp_id = terremark.servers.detect {|server| server.name == @name_args[0]}.id
        confirm("Do you really want to delete server ID #{vapp_id} named #{@name_args[0]}")

        puts "Cleaning up internet services..."
        private_ip = terremark.servers.get(vapp_id).ip_address
        internet_services = terremark.get_internet_services(terremark.default_vdc_id).body['InternetServices']
        public_ip_usage = {}
        internet_services.each do |internet_service|
          public_ip_address = internet_service['PublicIpAddress']['Name']
          public_ip_usage[public_ip_address] ||= []
          public_ip_usage[public_ip_address] << internet_service['Id']
        end
        internet_services.each do |internet_service|
          node_services = terremark.get_node_services(internet_service['Id']).body['NodeServices']
          node_services.delete_if do |node_service|
            if node_service['IpAddress'] == private_ip
              terremark.delete_node_service(node_service['Id'])
            end
          end
          if node_services.empty?
            terremark.delete_internet_service(internet_service['Id'])
            public_ip_usage.each_value {|internet_services| internet_services.delete(internet_service['Id'])}
            if public_ip_usage[internet_service['PublicIpAddress']['Name']].empty?
              terremark.delete_public_ip(internet_service['PublicIpAddress']['Id'])
            end
          end
        end

        power_off_task_id = terremark.power_off(vapp_id).body['href'].split('/').last
        print "Waiting for power off task [#{h.color(power_off_task_id, :bold)}]"
        terremark.tasks.get(power_off_task_id).wait_for { print '.'; ready? }
        print "\n"

        print "Deleting vApp #{h.color(vapp_id, :bold)}"
        delete_vapp_task_id = terremark.delete_vapp(vapp_id).headers['Location'].split('/').last
        terremark.tasks.get(delete_vapp_task_id).wait_for { print '.'; ready? }
        print "\n"
        
        Chef::Log.warn("Deleted server #{@name_args[0]}")
      end
    end
  end
end

