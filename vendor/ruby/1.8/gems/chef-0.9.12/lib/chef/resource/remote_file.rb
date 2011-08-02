#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require 'chef/resource/file'

class Chef
  class Resource
    class RemoteFile < Chef::Resource::File
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :remote_file
        @action = "create"
        @source = ::File.basename(name)
        @cookbook = nil
      end
      
      def source(args=nil)
        set_or_return(
          :source,
          args,
          :kind_of => String
        )
      end
      
      def cookbook(args=nil)
        set_or_return(
          :cookbook,
          args,
          :kind_of => String
        )
      end

      def checksum(args=nil)
        set_or_return(
          :checksum,
          args,
          :kind_of => String
        )
      end

      # The provider that should be used for this resource.
      # === Returns:
      # Chef::Provider::RemoteFile    when the source is an absolute URI, like
      #                               http://www.google.com/robots.txt
      # Chef::Provider::CookbookFile  when the source is a relative URI, like
      #                               'myscript.pl', 'dir/config.conf'
      def provider
        if absolute_uri?(source)
          Chef::Provider::RemoteFile
        else
          Chef::Log.warn("remote_file is deprecated for fetching files from cookbooks. Use cookbook_file instead")
          Chef::Log.warn("From #{self.to_s} on #{source_line}")
          Chef::Provider::CookbookFile
        end
      end

      private
      
      def absolute_uri?(source)
        URI.parse(source).absolute?
      rescue URI::InvalidURIError
        false
      end

    end
  end
end
