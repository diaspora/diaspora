#--
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
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

require 'extlib'

class Chef
  # == Chef::CookbookCollection
  # This class is the consistent interface for a node to obtain its
  # cookbooks by name.
  #
  # This class is basically a glorified Hash, but since there are
  # several ways this cookbook information is collected,
  # (e.g. CookbookLoader for solo, hash of auto-vivified Cookbook
  # objects for lazily-loaded remote cookbooks), it gets transformed
  # into this.
  class CookbookCollection < Mash

    # The input is a mapping of cookbook name to CookbookVersion objects. We
    # simply extract them
    def initialize(cookbook_versions={})
      super() do |hash, key|
        raise Chef::Exceptions::CookbookNotFound, "Cookbook #{key} not found"
      end
      cookbook_versions.each{ |cookbook_name, cookbook_version| self[cookbook_name] = cookbook_version }
    end
    
  end
end
