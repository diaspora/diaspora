#
# Author:: Cary Penniman (<cary@rightscale.com>)
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
class Chef
  class Resource

    # Sends a string from a recipe to a log provider
    #
    # log "some string to log" do
    #   level :info  # (default)  also supports :warn, :debug, and :error
    # end
    #    
    # === Example
    # log "your string to log" 
    #
    # or 
    #
    # log "a debug string" { level :debug }
    #  
    class Log < Chef::Resource
      
      # Initialize log resource with a name as the string to log 
      #
      # === Parameters
      # name<String>:: Message to log
      # collection<Array>:: Collection of included recipes
      # node<Chef::Node>:: Node where resource will be used
      def initialize(name, run_context=nil)
        super
        @resource_name = :log
        @level = :info
        @action = :write
      end
      
      # <Symbol> Log level, one of :debug, :info, :warn, :error or :fatal
      def level(arg=nil)
        set_or_return(
          :level,
          arg,
          :equal_to => [ :debug, :info, :warn, :error, :fatal ]
        )
      end
      
    end
  end  
end


