#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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
require 'chef/data_bag_item'

class Chef
  class Knife
    class DataBagFromFile < Knife

      banner "knife data bag from file BAG FILE (options)"
      category "data bag"

      def run 
        updated = load_from_file(Chef::DataBagItem, @name_args[1], @name_args[0])
        dbag = Chef::DataBagItem.new
        dbag.data_bag(@name_args[0])
        dbag.raw_data = updated
        dbag.save
        Chef::Log.info("Updated data_bag_item[#{@name_args[1]}]")
      end
    end
  end
end




