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
require 'chef/api_client'
require 'json'

class Chef
  class Knife
    class ClientCreate < Knife

      option :file,
        :short => "-f FILE",
        :long  => "--file FILE",
        :description => "Write the key to a file"
      
      option :admin,
        :short => "-a",
        :long  => "--admin",
        :description => "Create the client as an admin",
        :boolean => true

      banner "knife client create CLIENT (options)"

      def run
        @client_name = @name_args[0]

        if @client_name.nil?
          show_usage
          Chef::Log.fatal("You must specify a client name")
          exit 1
        end
        
        client = Chef::ApiClient.new
        client.name(@client_name)
        client.admin(config[:admin])
        
        output = edit_data(client)

        key = output.save

        Chef::Log.info("Created (or updated) #{output}")
        
        if config[:file]
          File.open(config[:file], "w") do |f|
            f.print(key['private_key'])
          end
        else
          puts key['private_key']
        end
      end
    end
  end
end

