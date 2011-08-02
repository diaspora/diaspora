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
require 'json'
require 'uri'

class Chef
  class Knife
    class CookbookShow < Knife

      banner "knife cookbook show COOKBOOK [VERSION] [PART] [FILENAME] (options)"

      option :fqdn,
       :short => "-f FQDN",
       :long => "--fqdn FQDN",
       :description => "The FQDN of the host to see the file for"

      option :platform,
       :short => "-p PLATFORM",
       :long => "--platform PLATFORM",
       :description => "The platform to see the file for"

      option :platform_version,
       :short => "-V VERSION",
       :long => "--platform-version VERSION",
       :description => "The platform version to see the file for"

      def run 
        case @name_args.length
        when 4 # We are showing a specific file
          node = Hash.new
          node[:fqdn] = config[:fqdn] if config.has_key?(:fqdn)
          node[:platform] = config[:platform] if config.has_key?(:platform)
          node[:platform_version] = config[:platform_version] if config.has_key?(:platform_version)

          class << node
            def attribute?(name)
              has_key?(name)
            end
          end

          cookbook_name, cookbook_version, segment, filename = @name_args[0..3]

          manifest = rest.get_rest("cookbooks/#{cookbook_name}/#{cookbook_version}")
          cookbook = Chef::CookbookVersion.new(cookbook_name)
          cookbook.manifest = manifest
          
          manifest_entry = cookbook.preferred_manifest_record(node, segment, filename)
          result = rest.get_rest("cookbooks/#{cookbook_name}/#{cookbook_version}/files/#{manifest_entry[:checksum]}")
          
          pretty_print(result)
        when 3 # We are showing a specific part of the cookbook
          cookbook_version = @name_args[1] == 'latest' ? '_latest' : @name_args[1]
          result = rest.get_rest("cookbooks/#{@name_args[0]}/#{cookbook_version}")
          output(result.manifest[@name_args[2]])
        when 2 # We are showing the whole cookbook data
          cookbook_version = @name_args[1] == 'latest' ? '_latest' : @name_args[1]
          output(rest.get_rest("cookbooks/#{@name_args[0]}/#{cookbook_version}"))
        when 1 # We are showing the cookbook versions 
          output(rest.get_rest("cookbooks/#{@name_args[0]}"))
        when 0
          show_usage
          Chef::Log.fatal("You must specify a cookbook name")
          exit 1
        end
      end

      def make_query_params(req_opts)
        query_part = Array.new 
        req_opts.keys.sort { |a,b| a.to_s <=> b.to_s }.each do |key|
          query_part << "#{key}=#{URI.escape(req_opts[key])}"
        end
        query_part.join("&")
      end

    end
  end
end




