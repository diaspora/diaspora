#
# Author:: Stephen Delano (<stephen@opscode.com>)
# Author:: Tim Hinderliter (<tim@opscode.com>)
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

class Chef
  class Knife
    class CookbookSiteUnshare < Knife

      banner "knife cookbook site unshare COOKBOOK"
      category "cookbook site"

      def run
        @cookbook_name = @name_args[0]
        if @cookbook_name.nil?
          show_usage
          Chef::Log.fatal "You must provide the name of the cookbook to unshare"
          exit 1
        end

        confirm "Do you really want to unshare the cookbook #{@cookbook_name}"

        begin
          rest.delete_rest "http://cookbooks.opscode.com/api/v1/cookbooks/#{@name_args[0]}"
        rescue Net::HTTPServerException => e
          raise e unless e.message =~ /Forbidden/
          Chef::Log.error "Forbidden: You must be the maintainer of #{@cookbook_name} to unshare it."
          exit 1
        end

        Chef::Log.info "Unshared cookbook #{@cookbook_name}"
      end

    end
  end
end
