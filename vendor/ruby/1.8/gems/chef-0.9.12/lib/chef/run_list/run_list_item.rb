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

class Chef
  class RunList
    class RunListItem
      QUALIFIED_RECIPE = %r{^recipe\[([^\]]+)\]$}
      QUALIFIED_ROLE   = %r{^role\[([^\]]+)\]$}

      attr_reader :name

      attr_reader :type

      def initialize(item)
        case item
        when Hash
          assert_hash_is_valid_run_list_item!(item)
          @type = (item['type'] || item[:type]).to_sym
          @name = item['name'] || item[:name]
        when String
          if match = QUALIFIED_RECIPE.match(item)
            @type = :recipe
            @name = match[1]
          elsif match = QUALIFIED_ROLE.match(item)
            @type = :role
            @name = match[1]
          else
            @type = :recipe
            @name = item
          end
        else
          raise ArgumentError, "Unable to create #{self.class} from #{item.class}:#{item.inspect}: must be a Hash or String"
        end
      end

      def to_s
        "#{@type}[#{@name}]"
      end

      def role?
        @type == :role
      end

      def recipe?
        @type == :recipe
      end

      def ==(other)
        if other.kind_of?(String)
          self.to_s == other.to_s
        else
          other.respond_to?(:type) && other.respond_to?(:name) && other.type == @type && other.name == @name
        end
      end

      def assert_hash_is_valid_run_list_item!(item)
        unless (item.key?('type')|| item.key?(:type)) && (item.key?('name') || item.key?(:name))
          raise ArgumentError, "Initializing a #{self.class} from a hash requires that it have a 'type' and 'name' key"
        end
      end

    end
  end
end
