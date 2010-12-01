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

require "chef/resource/scm"

class Chef
  class Resource
    class Subversion < Chef::Resource::Scm
      
      def initialize(name, run_context=nil)
        super
        @svn_arguments = '--no-auth-cache'
        @svn_info_args = '--no-auth-cache'
        @resource_name = :subversion
        @provider = Chef::Provider::Subversion
        allowed_actions << :force_export
      end
      
    end
  end
end
