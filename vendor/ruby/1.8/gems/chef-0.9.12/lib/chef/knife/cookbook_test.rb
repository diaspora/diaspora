#
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Matthew Kent (<mkent@magoazul.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# Copyright:: Copyright (c) 2010 Matthew Kent
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
require 'chef/checksum_cache'

class Chef
  class Knife
    class CookbookTest < Knife

      banner "knife cookbook test [COOKBOOKS...] (options)"

      option :cookbook_path,
        :short => "-o PATH:PATH",
        :long => "--cookbook-path PATH:PATH",
        :description => "A colon-separated path to look for cookbooks in",
        :proc => lambda { |o| o.split(":") }

      option :all,
        :short => "-a",
        :long => "--all",
        :description => "Test all cookbooks, rather than just a single cookbook"

      def run 
        if config[:cookbook_path]
          Chef::Config[:cookbook_path] = config[:cookbook_path]
        else
          config[:cookbook_path] = Chef::Config[:cookbook_path]
        end

        if config[:all]
          cl = Chef::CookbookLoader.new
          cl.each do |key, cookbook|
            test_cookbook(key)
          end
        else
          @name_args.each do |cb|
            test_cookbook(cb)
          end
        end
      end

      def test_cookbook(cookbook)
        Chef::Log.info("Running syntax check on #{cookbook}")
        Array(config[:cookbook_path]).reverse.each do |path|
          syntax_checker = Chef::Cookbook::SyntaxCheck.for_cookbook(cookbook, path)
          test_ruby(syntax_checker)
          test_templates(syntax_checker)
        end
      end


      def test_ruby(syntax_checker)
        Chef::Log.info("Validating ruby files")
        exit(1) unless syntax_checker.validate_ruby_files
      end
      
      def test_templates(syntax_checker)
        Chef::Log.info("Validating templates")
        exit(1) unless syntax_checker.validate_templates
      end

    end
  end
end
