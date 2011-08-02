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
    class ClientShow < Knife

      banner "knife client show CLIENT (options)"

      option :attribute,
        :short => "-a ATTR",
        :long => "--attribute ATTR",
        :description => "Show only one attribute"

      def run
        @client_name = @name_args[0]

        if @client_name.nil?
          show_usage
          Chef::Log.fatal("You must specify a client name")
          exit 1
        end
        
        client = Chef::ApiClient.load(@client_name)
        output(format_for_display(client))
      end

    end
  end
end

