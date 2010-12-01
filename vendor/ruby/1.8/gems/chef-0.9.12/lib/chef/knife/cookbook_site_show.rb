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
    class CookbookSiteShow < Knife

      banner "knife cookbook site show COOKBOOK [VERSION] (options)"
      category "cookbook site"

      def run
        case @name_args.length
        when 1 
          cookbook_data = rest.get_rest("http://cookbooks.opscode.com/api/v1/cookbooks/#{@name_args[0]}")
        when 2
          cookbook_data = rest.get_rest("http://cookbooks.opscode.com/api/v1/cookbooks/#{@name_args[0]}/versions/#{name_args[1].gsub('.', '_')}")
        end
        output(format_for_display(cookbook_data))
      end

      def get_cookbook_list(items=10, start=0, cookbook_collection={})
        cookbooks_url = "http://cookbooks.opscode.com/api/v1/cookbooks?items=#{items}&start=#{start}"
        cr = rest.get_rest(cookbooks_url)
        cr["items"].each do |cookbook|
          cookbook_collection[cookbook["cookbook_name"]] = cookbook
        end
        new_start = start + cr["items"].length
        if new_start < cr["total"]
          get_cookbook_list(items, new_start, cookbook_collection) 
        else
          cookbook_collection
        end
      end
    end
  end
end





