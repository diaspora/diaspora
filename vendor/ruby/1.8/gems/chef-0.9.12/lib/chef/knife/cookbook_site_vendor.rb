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
require 'chef/cookbook/metadata'

class Chef
  class Knife
    class CookbookSiteVendor < Knife

      banner "knife cookbook site vendor COOKBOOK [VERSION] (options)"
      category "cookbook site"

      option :deps,
       :short => "-d",
       :long => "--dependencies",
       :boolean => true,
       :description => "Grab dependencies automatically"

      option :cookbook_path,
        :short => "-o PATH:PATH",
        :long => "--cookbook-path PATH:PATH",
        :description => "A colon-separated path to look for cookbooks in",
        :proc => lambda { |o| o.split(":") }

      def run
        if config[:cookbook_path]
          Chef::Config[:cookbook_path] = config[:cookbook_path]
        else
          config[:cookbook_path] = Chef::Config[:cookbook_path]
        end

        # Check to ensure we have a valid source of cookbooks before continuing
        unless File.directory?(config[:cookbook_path].first)
          Chef::Log.error( File.join(config[:cookbook_path].first, " doesn't exist!.  Make sure you have cookbook_path configured correctly"))
          exit 1
        end

        vendor_path = File.expand_path(File.join(config[:cookbook_path].first))
        cookbook_path = File.join(vendor_path, name_args[0])
        upstream_file = File.join(vendor_path, "#{name_args[0]}.tar.gz")
        branch_name = "chef-vendor-#{name_args[0]}"

        download = Chef::Knife::CookbookSiteDownload.new
        download.config[:file] = upstream_file 
        download.name_args = name_args
        download.run

        Chef::Log.info("Checking out the master branch.")
        Chef::Mixin::Command.run_command(:command => "git checkout master", :cwd => vendor_path) 
        Chef::Log.info("Checking the status of the vendor branch.")
        status, branch_output, branch_error = Chef::Mixin::Command.output_of_command("git branch --no-color | grep #{branch_name}", :cwd => vendor_path) 
        if branch_output =~ /#{Regexp.escape(branch_name)}$/m
          Chef::Log.info("Vendor branch found.")
          Chef::Mixin::Command.run_command(:command => "git checkout #{branch_name}", :cwd => vendor_path)
        else
          Chef::Log.info("Creating vendor branch.")
          Chef::Mixin::Command.run_command(:command => "git checkout -b #{branch_name}", :cwd => vendor_path)
        end
        Chef::Log.info("Removing pre-existing version.")
        Chef::Mixin::Command.run_command(:command => "rm -r #{cookbook_path}", :cwd => vendor_path) if File.directory?(cookbook_path)
        Chef::Log.info("Uncompressing #{name_args[0]} version #{download.version}.")
        Chef::Mixin::Command.run_command(:command => "tar zxvf #{upstream_file}", :cwd => vendor_path)
        Chef::Mixin::Command.run_command(:command => "rm #{upstream_file}", :cwd => vendor_path)
        Chef::Log.info("Adding changes.")
        Chef::Mixin::Command.run_command(:command => "git add #{name_args[0]}", :cwd => vendor_path)

        Chef::Log.info("Committing changes.")
        changes = true
        begin
          Chef::Mixin::Command.run_command(:command => "git commit -a -m 'Import #{name_args[0]} version #{download.version}'", :cwd => vendor_path)
        rescue Chef::Exceptions::Exec => e
          Chef::Log.warn("Checking out the master branch.")
          Chef::Log.warn("No changes from current vendor #{name_args[0]}")
          Chef::Mixin::Command.run_command(:command => "git checkout master", :cwd => vendor_path) 
          changes = false
        end

        if changes
          Chef::Log.info("Creating tag chef-vendor-#{name_args[0]}-#{download.version}.")
          Chef::Mixin::Command.run_command(:command => "git tag -f chef-vendor-#{name_args[0]}-#{download.version}", :cwd => vendor_path)
          Chef::Log.info("Checking out the master branch.")
          Chef::Mixin::Command.run_command(:command => "git checkout master", :cwd => vendor_path)
          Chef::Log.info("Merging changes from #{name_args[0]} version #{download.version}.")

          Dir.chdir(vendor_path) do
            if system("git merge #{branch_name}")
              Chef::Log.info("Cookbook #{name_args[0]} version #{download.version} successfully vendored!")
            else
              Chef::Log.error("You have merge conflicts - please resolve manually!")
              Chef::Log.error("(Hint: cd #{vendor_path}; git status)") 
              exit 1
            end
          end
        end

        if config[:deps]
          md = Chef::Cookbook::Metadata.new
          md.from_file(File.join(cookbook_path, "metadata.rb"))
          md.dependencies.each do |cookbook, version_list|
            # Doesn't do versions.. yet
            nv = Chef::Knife::CookbookSiteVendor.new
            nv.config = config
            nv.name_args = [ cookbook ]
            nv.run
          end
        end
      end

    end
  end
end






