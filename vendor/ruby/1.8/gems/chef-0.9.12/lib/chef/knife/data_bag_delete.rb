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
require 'chef/data_bag'

class Chef
  class Knife
    class DataBagDelete < Knife

      banner "knife data bag delete BAG [ITEM] (options)"
      category "data bag"

      def run 
        if @name_args.length == 2
          delete_object(Chef::DataBagItem, @name_args[1], "data_bag_item") do
            rest.delete_rest("data/#{@name_args[0]}/#{@name_args[1]}")
          end
        elsif @name_args.length == 1
          delete_object(Chef::DataBag, @name_args[0], "data_bag") do
            rest.delete_rest("data/#{@name_args[0]}")
          end
        else
          show_usage
          Chef::Log.fatal("You must specify at least a data bag name")
          exit 1
        end
      end
    end
  end
end


