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
require 'chef/node'
require 'json'

class Chef
  class Knife
    class NodeShow < Knife

      banner "knife node show NODE (options)"

      option :attribute,
        :short => "-a [ATTR]",
        :long => "--attribute [ATTR]",
        :description => "Show only one attribute"

      option :run_list,
        :short => "-r",
        :long => "--run-list",
        :description => "Show only the run list"

      def run 
        @node_name = @name_args[0]

        if @node_name.nil?
          show_usage
          Chef::Log.fatal("You must specify a node name")
          exit 1
        end
        
        node = Chef::Node.load(@node_name)
        output(format_for_display(node))
      end
    end
  end
end

