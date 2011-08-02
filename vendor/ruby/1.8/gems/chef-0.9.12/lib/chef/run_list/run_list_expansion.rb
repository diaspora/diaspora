#
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

require 'extlib'

require 'chef/mixin/deep_merge'

require 'chef/role'
require 'chef/couchdb'
require 'chef/rest'

class Chef
  class RunList
    # Abstract Base class for expanding a run list. Subclasses must handle
    # fetching roles from a data source by defining +fetch_role+
    class RunListExpansion

      attr_reader :run_list_items

      attr_reader :recipes

      attr_reader :default_attrs

      attr_reader :override_attrs

      attr_reader :errors

      # The data source passed to the constructor. Not used in this class.
      # In subclasses, this is a couchdb or Chef::REST object pre-configured
      # to fetch roles from their correct location.
      attr_reader :source

      def initialize(run_list_items, source=nil)
        @errors = Array.new

        @run_list_items = run_list_items.dup
        @source = source

        @default_attrs = Mash.new
        @override_attrs = Mash.new

        @recipes = []

        @applied_roles = {}
      end

      # Did we find any errors (expanding roles)?
      def errors?
        @errors.length > 0
      end

      alias :invalid? :errors?

      # Iterates over the run list items, expanding roles. After this,
      # +recipes+ will contain the fully expanded recipe list
      def expand
        @run_list_items.each_with_index do |entry, index|
          case entry.type
          when :recipe
            recipes << entry.name unless recipes.include?(entry.name)
          when :role
            if role = inflate_role(entry.name)
              apply_role_attributes(role)
              @run_list_items.insert(index + 1, *role.run_list.run_list_items)
            end
          end
        end
      end

      # Fetches and inflates a role
      # === Returns
      # Chef::Role  in most cases
      # false       if the role has already been applied
      # nil         if the role does not exist
      def inflate_role(role_name)
        return false if applied_role?(role_name) # Prevent infinite loops
        applied_role(role_name)
        fetch_role(role_name)
      end

      def apply_role_attributes(role)
        @default_attrs = Chef::Mixin::DeepMerge.merge(@default_attrs, role.default_attributes)
        @override_attrs = Chef::Mixin::DeepMerge.merge(@override_attrs, role.override_attributes)
      end

      def applied_role?(role_name)
        @applied_roles.has_key?(role_name)
      end

      def applied_role(role_name)
        @applied_roles[role_name] = true
      end

      def roles
        @applied_roles.keys
      end

      # In subclasses, this method will fetch the role from the data source.
      def fetch_role(name)
        raise NotImplementedError
      end

      # When a role is not found, an error message is logged, but no
      # exception is raised.  We do add an entry in the errors collection.
      # === Returns
      # nil
      def role_not_found(name)
        Chef::Log.error("Role #{name} is in the runlist but does not exist. Skipping expand.")
        @errors << name
        nil
      end
    end

    # Expand a run list from disk. Suitable for chef-solo
    class RunListExpansionFromDisk < RunListExpansion

      def fetch_role(name)
        Chef::Role.from_disk(name)
      rescue Chef::Exceptions::RoleNotFound
        role_not_found(name)
      end

    end

    # Expand a run list from the chef-server API.
    class RunListExpansionFromAPI < RunListExpansion

      def rest
        @rest ||= (source || Chef::REST.new(Chef::Config[:role_url]))
      end

      def fetch_role(name)
        rest.get_rest("roles/#{name}")
      rescue Net::HTTPServerException => e
        if e.message == '404 "Not Found"'
          role_not_found(name)
        else
          raise
        end
      end
    end

    # Expand a run list from couchdb. Used in chef-server-api
    class RunListExpansionFromCouchDB < RunListExpansion

      def couchdb
        source
      end

      def fetch_role(name)
        Chef::Role.cdb_load(name, couchdb)
      rescue Chef::Exceptions::CouchDBNotFound
        role_not_found(name)
      end

    end
  end
end
