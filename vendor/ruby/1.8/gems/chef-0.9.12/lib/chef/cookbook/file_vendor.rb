#
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Tim Hinderliter (<tim@opscode.com>)
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


class Chef
  class Cookbook
    # == Chef::Cookbook::FileVendor
    # This class handles fetching of cookbook files based on specificity.
    class FileVendor

      def self.on_create(&block)
        @instance_creator = block
      end
      
      # Factory method that creates the appropriate kind of
      # Cookbook::FileVendor to serve the contents of the manifest
      def self.create_from_manifest(manifest)
        raise "Must call Chef::Cookbook::FileVendor.on_create before calling create_from_manifest factory" unless defined?(@instance_creator)
        @instance_creator.call(manifest)
      end
      
      # Gets the on-disk location for the given cookbook file.
      #
      # Subclasses are responsible for determining exactly how the
      # files are obtained and where they are stored.
      def get_filename(filename)
        raise NotImplemented, "Subclasses must implement this method"
      end
      
    end
  end
end
