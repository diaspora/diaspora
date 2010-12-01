#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008, 2009 Opscode, Inc.
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

require 'chef/log'

class Chef
  module Mixin
    module LanguageIncludeAttribute

      # Loads the attribute file specified by the short name of the
      # file, e.g., loads specified cookbook's
      #   "attributes/mailservers.rb"
      # if passed
      #   "mailservers"
      def include_attribute(*fully_qualified_attribute_short_filenames)
        if self.kind_of?(Chef::Node)
          node = self
        else
          node = @node
        end

        fully_qualified_attribute_short_filenames.flatten.each do |fully_qualified_attribute_short_filename|
          if node.run_state[:seen_attributes].has_key?(fully_qualified_attribute_short_filename)
            Chef::Log.debug("I am not loading attribute file #{fully_qualified_attribute_short_filename}, because I have already seen it.")
            next
          end

          Chef::Log.debug("Loading Attribute #{fully_qualified_attribute_short_filename}")
          node.run_state[:seen_attributes][fully_qualified_attribute_short_filename] = true

          if amatch = fully_qualified_attribute_short_filename.match(/(.+?)::(.+)/)
            cookbook_name = amatch[1].to_sym
            node.load_attribute_by_short_filename(amatch[2], cookbook_name)
          else
            cookbook_name = fully_qualified_attribute_short_filename.to_sym
            node.load_attribute_by_short_filename("default", cookbook_name)
          end
        end
        true
      end

    end
  end
end
      

