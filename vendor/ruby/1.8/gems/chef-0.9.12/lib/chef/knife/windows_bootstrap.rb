#
# Author:: Doug MacEachern <dougm@vmware.com>
# Copyright:: Copyright (c) 2010 VMware, Inc.
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

require 'fileutils'
require 'chef/knife/bootstrap.rb'

class Chef
  class Knife
    class WindowsBootstrap < Chef::Knife::Bootstrap

      banner "knife windows bootstrap FQDN [RUN LIST...] (options)"

      option :user,
        :short => "-x USERNAME",
        :long  => "--user USERNAME",
        :description => "The Windows username"

      option :password,
        :short => "-P PASSWORD",
        :long  => "--password PASSWORD",
        :description => "The Windows password"

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node"

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template",
        :default => "windows-gems"

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :default => false

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(",") },
        :default => []

      def is_mounted
        @net_use ||= Chef::Util::Windows::NetUse.new(@admin_share)
        begin
          @net_use.get_info
          return true
        rescue
          return false
        end
      end

      def mount_admin_share
        if @add_mount && !is_mounted
          use = {
            :remote => @admin_share, :local => '',
            :username => config[:user], :password => config[:password]
          }
          @net_use.add(use)
          if is_mounted
            Chef::Log.info("Mounted #{@admin_share} for copying files")
          else
            Chef::Log.fatal("Failed to mount #{@admin_share}")
            exit 1
          end
        end
      end

      def unmount_admin_share
        if @add_mount && is_mounted
          Chef::Log.debug("Unmounting #{@admin_share}")
          @net_use.delete
        end
      end

      def psexec(args)
        cmd = ['psexec', @unc_path, "-h", "-w", 'c:\chef\tmp']
        if config[:user]
          cmd << "-u" << config[:user]
        end
        if config[:password]
          cmd << "-p" << config[:password]
        end
        cmd << args
        cmd = cmd.join(' ')
        Chef::Log.debug("system #{cmd}")
        system(cmd)
      end

      def run
        require 'chef/util/windows/net_use'

        if @name_args.first == nil
          Chef::Log.error("Must pass a node name/ip to windows bootstrap")
          exit 1
        end

        config[:server_name] = @name_args.first
        if Chef::Config[:http_proxy]
          uri = URI.parse(Chef::Config[:http_proxy])
          config[:proxy] = "#{uri.host}:#{uri.port}"
        end

        @unc_path = "\\\\#{config[:server_name]}"
        @admin_share = "#{@unc_path}\\c$"
        path = "#{@admin_share}\\chef"
        etc = "#{path}\\etc"
        tmp = "#{path}\\tmp"

        $stdout.sync = true

        command = render_template(load_template(config[:bootstrap_template]))

        Chef::Log.info("Bootstrapping Chef on #{config[:server_name]}")

        @add_mount = config[:user] != nil && !is_mounted
        mount_admin_share

        begin
          [etc, tmp, "#{path}\\log"].each do |dir|
            unless File.exists?(dir)
              Chef::Log.debug("mkdir_p #{dir}")
              FileUtils.mkdir_p(dir)
            end
          end
          File.open("#{tmp}\\bootstrap.bat", 'w') {|f| f.write(command) }
          FileUtils.cp(File.join(File.dirname(__FILE__), 'bootstrap', 'client-install.vbs'), tmp)
          FileUtils.cp(Chef::Config[:validation_key], etc)
          psexec("cmd.exe /c bootstrap.bat")
        ensure
          unmount_admin_share
        end
      end
    end
  end
end
