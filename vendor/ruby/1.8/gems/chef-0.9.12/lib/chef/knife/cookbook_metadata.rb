#
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

class Chef
  class Knife
    class CookbookMetadata < Knife

      banner "knife cookbook metadata COOKBOOK (options)"

      option :cookbook_path,
        :short => "-o PATH:PATH",
        :long => "--cookbook-path PATH:PATH",
        :description => "A colon-separated path to look for cookbooks in",
        :proc => lambda { |o| o.split(":") }

      option :all,
        :short => "-a",
        :long => "--all",
        :description => "Generate metadata for all cookbooks, rather than just a single cookbook"

      def run
        if config[:cookbook_path]
          Chef::Config[:cookbook_path] = config[:cookbook_path]
        else
          config[:cookbook_path] = Chef::Config[:cookbook_path]
        end

        if config[:all]
          cl = Chef::CookbookLoader.new
          cl.each do |cname, cookbook|
            generate_metadata(cname.to_s)
          end
        else
          generate_metadata(@name_args[0])
        end
      end

      def generate_metadata(cookbook)
        Chef::Log.info("Generating Metadata")
        Array(config[:cookbook_path]).reverse.each do |path|
          file = File.expand_path(File.join(path, cookbook, 'metadata.rb'))
          generate_metadata_from_file(cookbook, file)
        end
      end

      def generate_metadata_from_file(cookbook, file)
        if File.exists?(file)
          Chef::Log.debug("Generating metadata for #{cookbook} from #{file}")
          md = Chef::Cookbook::Metadata.new
          md.name(cookbook)
          md.from_file(file)
          json_file = File.join(File.dirname(file), 'metadata.json')
          File.open(json_file, "w") do |f|
            f.write(JSON.pretty_generate(md))
          end
          generated = true
          Chef::Log.debug("Generated #{json_file}")
        else
          Chef::Log.debug("No #{file} found; skipping!")
        end
      end
    end
  end
end
