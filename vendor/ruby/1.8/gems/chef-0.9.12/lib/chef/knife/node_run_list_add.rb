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
    class NodeRunListAdd < Knife

      banner "knife node run_list add [NODE] [ENTRY] (options)"

      option :after,
        :short => "-a ITEM",
        :long  => "--after ITEM",
        :description => "Place the ENTRY in the run list after ITEM"

      def run 
        node = Chef::Node.load(@name_args[0])
        entry = @name_args[1]
       
        add_to_run_list(node, entry, config[:after])

        node.save

        config[:run_list] = true

        output(format_for_display(node)) 
      end

      def add_to_run_list(node, new_value, after=nil)
        if after
          nlist = []
          node.run_list.each do |entry|
            nlist << entry
            if entry == after
              nlist << new_value
            end
          end
          node.run_list.reset!(nlist)
        else
          node.run_list << new_value
        end
      end

    end
  end
end
