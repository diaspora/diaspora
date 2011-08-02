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

class Chef
  class Knife
    class Configure < Knife
      attr_reader :chef_server, :new_client_name, :admin_client_name, :admin_client_key
      attr_reader :chef_repo, :new_client_key, :validation_client_name, :validation_key

      banner "knife configure (options)"

      option :repository,
        :short => "-r REPO",
        :long => "--repository REPO",
        :description => "The path to your chef-repo"

      option :initial,
        :short => "-i",
        :long => "--initial",
        :boolean => true,
        :description => "Create an initial API Client"

      def configure_chef
        # We are just faking out the system so that you can do this without a key specified
        Chef::Config[:node_name] = 'woot'
        super
        Chef::Config[:node_name] = nil
      end

      def run
        ask_user_for_config_path

        Mixlib::Log::Formatter.show_time = false
        Chef::Log.init(STDOUT)
        Chef::Log.level(:info)

        FileUtils.mkdir_p(chef_config_path)

        ask_user_for_config

        ::File.open(config[:config_file], "w") do |f|
          f.puts <<-EOH
log_level                :info
log_location             STDOUT
node_name                '#{new_client_name}'
client_key               '#{new_client_key}'
validation_client_name   '#{validation_client_name}'
validation_key           '#{validation_key}'
chef_server_url          '#{chef_server}'
cache_type               'BasicFile'
cache_options( :path => '#{File.join(chef_config_path, "checksums")}' )
EOH
          unless chef_repo.empty?
            f.puts "cookbook_path [ '#{chef_repo}/cookbooks', '#{chef_repo}/site-cookbooks' ]"
          end
        end

        if config[:initial]
          Chef::Log.warn("Creating initial API user...")
          Chef::Config[:chef_server_url] = chef_server
          Chef::Config[:node_name] = admin_client_name
          Chef::Config[:client_key] = admin_client_key
          client_create = Chef::Knife::ClientCreate.new
          client_create.name_args = [ new_client_name ]
          client_create.config[:admin] = true
          client_create.config[:file] = new_client_key
          client_create.config[:yes] = true
          client_create.config[:no_editor] = true
          client_create.run
        else
          Chef::Log.warn("*****")
          Chef::Log.warn("")
          Chef::Log.warn("You must place your client key in:")
          Chef::Log.warn("  #{new_client_key}")
          Chef::Log.warn("Before running commands with Knife!")
          Chef::Log.warn("")
          Chef::Log.warn("*****")
          Chef::Log.warn("")
          Chef::Log.warn("You must place your validation key in:")
          Chef::Log.warn("  #{validation_key}")
          Chef::Log.warn("Before generating instance data with Knife!")
          Chef::Log.warn("")
          Chef::Log.warn("*****")
        end

        Chef::Log.warn("Configuration file written to #{config[:config_file]}")
      end

      def ask_user_for_config_path
        config[:config_file] ||= ask_question("Where should I put the config file? ", :default => '~/.chef/knife.rb')
        # have to use expand path to expand the tilde character to the user's home
        config[:config_file] = File.expand_path(config[:config_file])
        if File.exists?(config[:config_file])
          confirm("Overwrite #{config[:config_file]}")
        end
      end

      def ask_user_for_config
        @chef_server            = config[:chef_server_url] || ask_question("Please enter the chef server URL: ", :default => 'http://localhost:4000')
        if config[:initial]
          @new_client_name        = config[:node_name] || ask_question("Please enter a clientname for the new client: ", :default => Etc.getlogin)
          @admin_client_name      = config[:admin_client_name] || ask_question("Please enter the existing admin clientname: ", :default => 'chef-webui')
          @admin_client_key       = config[:admin_client_key] || ask_question("Please enter the location of the existing admin client's private key: ", :default => '/etc/chef/webui.pem')
        else
          @new_client_name        = config[:node_name] || ask_question("Please enter an existing username or clientname for the API: ", :default => Etc.getlogin)
        end
        @validation_client_name = config[:validation_client_name] || ask_question("Please enter the validation clientname: ", :default => 'chef-validator')
        @validation_key         = config[:validation_key] || ask_question("Please enter the location of the validation key: ", :default => '/etc/chef/validation.pem')
        @chef_repo              = config[:repository] || ask_question("Please enter the path to a chef repository (or leave blank): ")

        @new_client_key = config[:client_key] || File.join(chef_config_path, "#{@new_client_name}.pem")
      end

      def config_file
        config[:config_file]
      end

      def chef_config_path
        File.dirname(config_file)
      end
    end
  end
end
