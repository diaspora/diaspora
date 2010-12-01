#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2009, 2010 Opscode, Inc.
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
require 'chef/knife/cookbook_delete'

class Chef
  class Knife
    class CookbookBulkDelete < Knife

      option :purge, :short => '-p', :long => '--purge', :boolean => true, :description => 'Permanently remove files from backing data store'
      
      banner "knife cookbook bulk delete REGEX (options)"

      def run
        unless regex_str = @name_args.first
          Chef::Log.fatal("You must supply a regular expression to match the results against")
          exit 42
        end

        regex = Regexp.new(regex_str)

        all_cookbooks = Chef::CookbookVersion.list
        cookbooks_names = all_cookbooks.keys.grep(regex)
        cookbooks_to_delete = cookbooks_names.inject({}) { |hash, name| hash[name] = all_cookbooks[name];hash }
        output(format_list_for_display(cookbooks_to_delete))

        confirm("Do you really want to delete these cookbooks? All versions will be deleted. (Y/N) ", false)
        
        confirm("Files that are common to multiple cookbooks are shared, so purging the files may disable other cookbooks. Are you sure you want to purge files instead of just deleting the cookbooks") if config[:purge]
        
        cookbooks_names.each do |cookbook_name|
          versions = rest.get_rest("cookbooks/#{cookbook_name}").values.flatten
          versions.each do |version|
            object = rest.delete_rest("cookbooks/#{cookbook_name}/#{version}#{config[:purge] ? "?purge=true" : ""}")
            Chef::Log.info("Deleted cookbook  #{cookbook_name.ljust(25)} [#{version}]")
          end
        end
      end
    end
  end
end
