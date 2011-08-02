#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuoyan@opscode.com>)
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Copyright:: Copyright (c) 2008-2010 Opscode, Inc.
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

require 'chef/run_list/run_list_item'
require 'chef/run_list/run_list_expansion'

class Chef
  class RunList
    include Enumerable

    # @run_list_items is an array of RunListItems that describe the items to 
    # execute in order. RunListItems can load from and convert to the string
    # forms users set on roles and nodes.
    # For example:
    #   @run_list_items = ['recipe[foo::bar]', 'role[webserver]']
    # Thus,
    #   self.role_names would return ['webserver']
    #   self.recipe_names would return ['foo::bar']
    attr_reader :run_list_items

    # For backwards compat
    alias :run_list :run_list_items

    def initialize
      @run_list_items = Array.new
    end

    def role_names
      @run_list_items.inject([]){|memo, run_list_item| memo << run_list_item.name if run_list_item.role? ; memo}
    end

    alias :roles :role_names

    def recipe_names
      @run_list_items.inject([]){|memo, run_list_item| memo << run_list_item.name if run_list_item.recipe? ; memo}
    end

    alias :recipes :recipe_names

    # Add an item of the form "recipe[foo::bar]" or "role[webserver]";
    # takes a String or a RunListItem
    def <<(run_list_item)
      run_list_item = run_list_item.kind_of?(RunListItem) ? run_list_item : parse_entry(run_list_item)
      @run_list_items << run_list_item unless @run_list_items.include?(run_list_item)
      self
    end

    def ==(other)
      if other.kind_of?(Chef::RunList)
        other.run_list_items == @run_list_items
      else
        return false unless other.respond_to?(:size) && (other.size == @run_list_items.size)
        other_run_list_items = other.dup

        other_run_list_items.map! { |item| item.kind_of?(RunListItem) ? item : RunListItem.new(item) }
        other_run_list_items == @run_list_items
      end
    end

    def to_s
      @run_list_items.join(", ")
    end

    def empty?
      @run_list_items.length == 0 ? true : false
    end

    def [](pos)
      @run_list_items[pos]
    end

    def []=(pos, item)
      @run_list_items[pos] = parse_entry(item)
    end

    def each(&block)
      @run_list_items.each { |i| block.call(i) }
    end

    def each_index(&block)
      @run_list_items.each_index { |i| block.call(i) }
    end

    def include?(item)
      @run_list_items.include?(parse_entry(item))
    end

    def reset!(*args)
      @run_list_items.clear
      args.flatten.each do |item|
        if item.kind_of?(Chef::RunList)
          item.each { |r| self << r }
        else
          self << item
        end
      end
      self
    end

    def remove(item)
      @run_list_items.delete_if{|i| i == item}
      self
    end

    def expand(data_source='server', couchdb=nil, rest=nil)
      couchdb = couchdb ? couchdb : Chef::CouchDB.new

      expansion = expansion_for_data_source(data_source, :couchdb => couchdb, :rest => rest)
      expansion.expand
      expansion
    end

    # Converts a string run list entry to a RunListItem object.
    # TODO: 5/27/2010 cw: this method has become nothing more than a proxy, revisit its necessity
    def parse_entry(entry)
      RunListItem.new(entry)
    end

    def expansion_for_data_source(data_source, opts={})
      data_source = 'disk' if Chef::Config[:solo]
      case data_source.to_s
      when 'disk'
        RunListExpansionFromDisk.new(@run_list_items)
      when 'server'
        RunListExpansionFromAPI.new(@run_list_items, opts[:rest])
      when 'couchdb'
        RunListExpansionFromCouchDB.new(@run_list_items, opts[:couchdb])
      end
    end

  end
end

