#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
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


require 'chef/resource'

class Chef
  class Resource
    class Scm < Chef::Resource
      
      def initialize(name, run_context=nil)
        super
        @destination = name
        @resource_name = :scm
        @enable_submodules = false
        @revision = "HEAD"
        @remote = "origin"
        @ssh_wrapper = nil
        @depth = nil
        @allowed_actions.push(:checkout, :export, :sync, :diff, :log)
      end

      def destination(arg=nil)
        set_or_return(
          :destination,
          arg,
          :kind_of => String
        )
      end

      def repository(arg=nil)
        set_or_return(
          :repository,
          arg,
          :kind_of => String
        )
      end

      def revision(arg=nil)
        set_or_return(
          :revision,
          arg,
          :kind_of => String
        )
      end

      def user(arg=nil)
        set_or_return(
          :user,
          arg,
          :kind_of => [String, Integer]
        )
      end

      def group(arg=nil)
        set_or_return(
          :group,
          arg,
          :kind_of => [String, Integer]
        )
      end

      def svn_username(arg=nil)
        set_or_return(
          :svn_username,
          arg,
          :kind_of => String
        )
      end

      def svn_password(arg=nil)
        set_or_return(
          :svn_password,
          arg,
          :kind_of => String
        )
      end

      def svn_arguments(arg=nil)
        @svn_arguments, arg = nil, nil if arg == false
        set_or_return(
          :svn_arguments,
          arg,
          :kind_of => String
        )
      end

      def svn_info_args(arg=nil)
        @svn_info_args, arg = nil, nil if arg == false
        set_or_return(
          :svn_info_args,
          arg,
          :kind_of => String)
      end

      # Capistrano and git-deploy use ``shallow clone''
      def depth(arg=nil)
        set_or_return(
          :depth,
          arg,
          :kind_of => Integer
        )
      end

      def enable_submodules(arg=nil)
        set_or_return(
          :enable_submodules,
          arg,
          :kind_of => [TrueClass, FalseClass]
        )
      end

      def remote(arg=nil)
        set_or_return(
          :remote,
          arg,
          :kind_of => String
        )
      end

      def ssh_wrapper(arg=nil)
        set_or_return(
          :ssh_wrapper,
          arg,
          :kind_of => String
        )
      end

    end
  end
end
