#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
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
require 'chef/cookbook_loader'
require 'chef/cookbook_uploader'

class Chef
  class Knife
    class CookbookUpload < Knife
      include Chef::Mixin::ShellOut

      banner "knife cookbook upload [COOKBOOKS...] (options)"

      option :cookbook_path,
        :short => "-o PATH:PATH",
        :long => "--cookbook-path PATH:PATH",
        :description => "A colon-separated path to look for cookbooks in",
        :proc => lambda { |o| o.split(":") }

      option :all,
        :short => "-a",
        :long => "--all",
        :description => "Upload all cookbooks, rather than just a single cookbook"

      def run 
        if config[:cookbook_path]
          Chef::Config[:cookbook_path] = config[:cookbook_path]
        else
          config[:cookbook_path] = Chef::Config[:cookbook_path]
        end

        Chef::Cookbook::FileVendor.on_create { |manifest| Chef::Cookbook::FileSystemFileVendor.new(manifest) }

        cl = Chef::CookbookLoader.new

        humanize_auth_exceptions do
          if config[:all]
            cl.each do |cookbook_name, cookbook|
              Chef::Log.info("** #{cookbook.name.to_s} **")
              Chef::CookbookUploader.upload_cookbook(cookbook)
            end
          else
            if @name_args.length < 1
              show_usage
              Chef::Log.fatal("You must specify the --all flag or at least one cookbook name")
              exit 1
            end
            @name_args.each do |cookbook_name|
              if cl.cookbook_exists?(cookbook_name)
                Chef::CookbookUploader.upload_cookbook(cl[cookbook_name])
              else
                Chef::Log.error("Could not find cookbook #{cookbook_name} in your cookbook path, skipping it")
              end
            end
          end
        end
      end

      private

      def humanize_auth_exceptions
        begin
          yield
        rescue Net::HTTPServerException => e
          case e.response.code
          when "401"
            Chef::Log.fatal "Request failed due to authentication (#{e}), check your client configuration (username, key)"
            exit 18
          else
            raise
          end
        end
      end


    end
  end
end
