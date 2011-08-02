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
    class Template < Chef::Resource::File
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :template
        @action = "create"
        @source = "#{::File.basename(name)}.erb"
        @cookbook = nil
        @local = false
        @variables = Hash.new
      end

      def source(file=nil)
        set_or_return(
          :source,
          file,
          :kind_of => [ String ]
        )
      end

      def variables(args=nil)
        set_or_return(
          :variables,
          args,
          :kind_of => [ Hash ]
        )
      end
      
      def cookbook(args=nil)
        set_or_return(
          :cookbook,
          args,
          :kind_of => [ String ]
        )
      end

      def local(args=nil)
        set_or_return(
          :local,
          args,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

    end
  end
end
