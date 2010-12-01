#--
# Author:: Daniel DeLeo (<dan@opscode.com>)
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

require 'chef/shell_out'

class Chef
  module Mixin
    module ShellOut
      
      def shell_out(*command_args)
        cmd = Chef::ShellOut.new(*command_args)
        cmd.run_command
        cmd
      end
      
      def shell_out!(*command_args)
        cmd = Chef::ShellOut.new(*command_args)
        cmd.run_command
        cmd.error!
        cmd
      end
    end
  end
end
