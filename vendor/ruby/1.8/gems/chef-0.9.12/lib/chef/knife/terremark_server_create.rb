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
require 'tempfile'

class Chef
  class Knife
    class TerremarkServerCreate < Knife

      banner "knife terremark server create NAME [RUN LIST...] (options)"

      option :terremark_password,
        :short => "-K PASSWORD",
        :long => "--terremark-password PASSWORD",
        :description => "Your terremark password",
        :proc => Proc.new { |key| Chef::Config[:knife][:terremark_password] = key } 

      option :terremark_username,
        :short => "-A USERNAME",
        :long => "--terremark-username USERNAME",
        :description => "Your terremark username",
        :proc => Proc.new { |username| Chef::Config[:knife][:terremark_username] = username } 

      option :terremark_service,
        :short => "-S SERVICE",
        :long => "--terremark-service SERVICE",
        :description => "Your terremark service name",
        :proc => Proc.new { |service| Chef::Config[:knife][:terremark_service] = service } 

      def h
        @highline ||= HighLine.new
      end

      def run 
        require 'fog'
        require 'highline'
        require 'net/ssh/multi'
        require 'readline'
        require 'net/scp'

        server_name = @name_args[0]

        terremark = Fog::Terremark.new(
          :terremark_username => Chef::Config[:knife][:terremark_username],
          :terremark_password => Chef::Config[:knife][:terremark_password],
          :terremark_service  => Chef::Config[:knife][:terremark_service] || :vcloud
        )

        $stdout.sync = true

        puts "Instantiating vApp #{h.color(server_name, :bold)}"
        vapp_id = terremark.instantiate_vapp_template(server_name).body['href'].split('/').last

        deploy_task_id = terremark.deploy_vapp(vapp_id).body['href'].split('/').last
        print "Waiting for deploy task [#{h.color(deploy_task_id, :bold)}]"
        terremark.tasks.get(deploy_task_id).wait_for { print "."; ready? }
        print "\n"

        power_on_task_id = terremark.power_on(vapp_id).body['href'].split('/').last
        print "Waiting for power on task [#{h.color(power_on_task_id, :bold)}]"
        terremark.tasks.get(power_on_task_id).wait_for { print "."; ready? }
        print "\n"

        private_ip = terremark.get_vapp(vapp_id).body['IpAddress']
        ssh_internet_service = terremark.create_internet_service(terremark.default_vdc_id, 'SSH', 'TCP', 22).body
        ssh_internet_service_id = ssh_internet_service['Id']
        public_ip = ssh_internet_service['PublicIpAddress']['Name']
        public_ip_id = ssh_internet_service['PublicIpAddress']['Id']
        ssh_node_service_id = terremark.add_node_service(ssh_internet_service_id, private_ip, 'SSH', 22).body['Id']

        puts "\nBootstrapping #{h.color(server_name, :bold)}..."
        password = terremark.get_vapp_template(12).body['Description'].scan(/\npassword: (.*)\n/).first.first

        command =  <<EOH
bash -c '
echo nameserver 208.67.222.222 > /etc/resolv.conf
echo nameserver 208.67.220.220 >> /etc/resolv.conf

if [ ! -f /usr/bin/chef-client ]; then
  apt-get update
  apt-get install -y ruby ruby1.8-dev build-essential wget libruby-extras libruby1.8-extras
  cd /tmp
  wget http://rubyforge.org/frs/download.php/69365/rubygems-1.3.6.tgz
  tar xvf rubygems-1.3.6.tgz
  cd rubygems-1.3.6
  ruby setup.rb
  cp /usr/bin/gem1.8 /usr/bin/gem
  gem install chef ohai --no-rdoc --no-ri --verbose
fi

mkdir -p /etc/chef

(
cat <<'EOP'
#{IO.read(Chef::Config[:validation_key])}
EOP
) > /etc/chef/validation.pem

(
cat <<'EOP'
log_level        :info
log_location     STDOUT
chef_server_url  "#{Chef::Config[:chef_server_url]}" 
validation_client_name "#{Chef::Config[:validation_client_name]}"
EOP
) > /etc/chef/client.rb

(
cat <<'EOP'
#{{ "run_list" => @name_args[1..-1] }.to_json}
EOP
) > /etc/chef/first-boot.json

/usr/bin/chef-client -j /etc/chef/first-boot.json'
EOH

        begin
          ssh = Chef::Knife::Ssh.new
          ssh.name_args = [ public_ip, "sudo #{command}" ]
          ssh.config[:ssh_user] = "vcloud"
          ssh.config[:manual] = true
          ssh.config[:password] = password
          ssh.password = password
          ssh.run
        rescue Errno::ETIMEDOUT
          puts "Timed out on bootstrap, re-trying. Hit CTRL-C to abort."
          puts "You probably need to log in to Terremark and powercycle #{h.color(@name_args[0], :bold)}"
          retry
        end

      end
    end
  end
end

