#
# Author:: Jason Jackson (jason.jackson@monster.com)
# Copyright:: Copyright (c) 2009 Jason Jackson
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

require 'chef/log'
require 'chef/mixin/command'
require 'chef/provider'
require 'erb'

class Chef
  class Provider
    class Ifconfig < Chef::Provider
      include Chef::Mixin::Command

      def load_current_resource
        @current_resource = Chef::Resource::Ifconfig.new(@new_resource.name)

        @interfaces = {}

        status = popen4("ifconfig") do |pid, stdin, stdout, stderr|
          stdout.each do |line|

            if !line[0..9].strip.empty?
              @int_name = line[0..9].strip
              @interfaces[@int_name] = {"hwaddr" => (line =~ /(HWaddr)/ ? ($') : "nil").strip.chomp }
            else
              @interfaces[@int_name]["inet_addr"] = (line =~ /inet addr:(\S+)/ ? ($1) : "nil") if line =~ /inet addr:/
              @interfaces[@int_name]["bcast"] = (line =~ /Bcast:(\S+)/ ? ($1) : "nil") if line =~ /Bcast:/
              @interfaces[@int_name]["mask"] = (line =~ /Mask:(\S+)/ ? ($1) : "nil") if line =~ /Mask:/
              @interfaces[@int_name]["mtu"] = (line =~ /MTU:(\S+)/ ? ($1) : "nil") if line =~ /MTU:/
              @interfaces[@int_name]["metric"] = (line =~ /Metric:(\S+)/ ? ($1) : "nil") if line =~ /Metric:/
            end

            if @interfaces.has_key?(@new_resource.device)
              @interface = @interfaces.fetch(@new_resource.device)

              @current_resource.target(@new_resource.target)
              @current_resource.device(@int_name)
              @current_resource.inet_addr(@interface["inet_addr"])
              @current_resource.hwaddr(@interface["hwaddr"])
              @current_resource.bcast(@interface["bcast"])
              @current_resource.mask(@interface["mask"])
              @current_resource.mtu(@interface["mtu"])
              @current_resource.metric(@interface["metric"])
            end
          end
        end

        unless status.exitstatus == 0
          raise Chef::Exception::Ifconfig, "ifconfig failed - #{status.inspect}!"
        end

        @current_resource
      end

      def action_add
        # check to see if load_current_resource found ifconfig
        unless @current_resource.inet_addr
          unless @new_resource.device == "lo"
            command = "ifconfig #{@new_resource.device} #{@new_resource.name}"
            command << " netmask #{@new_resource.mask}" if @new_resource.mask
            command << " metric #{@new_resource.metric}" if @new_resource.metric
            command << " mtu #{@new_resource.mtu}" if @new_resource.mtu
          end
  
          run_command(
            :command => command
          )
          @new_resource.updated_by_last_action(true)

        end

        # Write out the config files
        generate_config
      end

      def action_delete
        # check to see if load_current_resource found the interface
        if @current_resource.device
          command = "ifconfig #{@new_resource.device} down"
  
          run_command(
            :command => command
          )
          @new_resource.updated_by_last_action(true)
        else
          Chef::Log.debug("Ifconfig #{@current_resource} does not exist")
        end
      end

      # This is a little lame of me, as if any of these values aren't filled out it leaves blank lines
      # in the file.  Can refactor later to have this nice and tight.
      def generate_config
        b = binding
        case node[:platform]
        when "centos","redhat","fedora"
          content = %{
<% if @new_resource.device %>DEVICE=<%= @new_resource.device %><% end %>
<% if @new_resource.onboot %>ONBOOT=<%= @new_resource.onboot %><% end %>
<% if @new_resource.bootproto %>BOOTPROTO=<%= @new_resource.bootproto %><% end %>
<% if @new_resource.target %>IPADDR=<%= @new_resource.target %><% end %>
<% if @new_resource.mask %>NETMASK=<%= @new_resource.mask %><% end %>
<% if @new_resource.network %>NETWORK=<%= @new_resource.network %><% end %>
<% if @new_resource.bcast %>BROADCAST=<%= @new_resource.bcast %><% end %>
          }
          template = ::ERB.new(content)
          network_file = ::File.new("/etc/sysconfig/network-scripts/ifcfg-#{@new_resource.device}", "w")
          network_file.puts(template.result(b))
          network_file.close
        when "debian","ubuntu"
          # template
        when "slackware"
          # template
        end
      end 
    end
  end
end
