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
    class DataBagCreate < Knife

      banner "knife data bag create BAG [ITEM] (options)"
      category "data bag"

      def run
        @data_bag_name, @data_bag_item_name = @name_args

        if @data_bag_name.nil?
          show_usage
          Chef::Log.fatal("You must specify a data bag name")
          exit 1
        end
        
        # create the data bag
        begin
          rest.post_rest("data", { "name" => @data_bag_name })
          Chef::Log.info("Created data_bag[#{@data_bag_name}]")
        rescue Net::HTTPServerException => e
          raise unless e.to_s =~ /^409/
          Chef::Log.info("Data bag #{@data_bag_name} already exists")
        end
        
        # if an item is specified, create it, as well
        if @data_bag_item_name
          create_object({ "id" => @data_bag_item_name }, "data_bag_item[#{@data_bag_item_name}]") do |output|
            rest.post_rest("data/#{@data_bag_name}", output)
          end
        end
      end
    end
  end
end



