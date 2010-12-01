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
    class CookbookSiteDownload < Knife

      attr_reader :version

      banner "knife cookbook site download COOKBOOK [VERSION] (options)"
      category "cookbook site"

      option :file,
       :short => "-f FILE",
       :long => "--file FILE",
       :description => "The filename to write to"

      def run
        if @name_args.length == 1
          current = rest.get_rest("http://cookbooks.opscode.com/api/v1/cookbooks/#{name_args[0]}")
          cookbook_data = rest.get_rest(current["latest_version"])
        else
          cookbook_data = rest.get_rest("http://cookbooks.opscode.com/api/v1/cookbooks/#{name_args[0]}/versions/#{name_args[1].gsub('.', '_')}")
        end

        @version = cookbook_data['version']

        Chef::Log.info("Downloading #{@name_args[0]} from the cookbooks site at version #{cookbook_data['version']}")
        rest.sign_on_redirect = false
        tf = rest.get_rest(cookbook_data["file"], true)
        unless config[:file]
          config[:file] = File.join(Dir.pwd, "#{@name_args[0]}-#{cookbook_data['version']}.tar.gz")
        end
        FileUtils.cp(tf.path, config[:file])
        Chef::Log.info("Cookbook saved: #{config[:file]}")
      end

    end
  end
end


