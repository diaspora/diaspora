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
    class DataBagShow < Knife

      banner "knife data bag show BAG [ITEM] (options)"
      category "data bag"

      def run
        display = case @name_args.length
                  when 2
                    format_for_display(Chef::DataBagItem.load(@name_args[0], @name_args[1]))
                  else
                    format_list_for_display(Chef::DataBag.load(@name_args[0]))
                  end
        output(display)
      end
    end
  end
end

