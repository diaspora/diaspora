#
# Author:: Adam Jacob (<adam@opscode.com>)
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

require 'chef/search/query'
require 'chef/data_bag'
require 'chef/data_bag_item'

class Chef
  module Mixin
    module Language

      # Implementation class for determining platform dependent values
      class PlatformDependentValue

        # Create a platform dependent value object.
        # === Arguments
        # platform_hash (Hash) a hash of the same structure as Chef::Platform,
        # like this:
        #   {
        #     :debian => {:default => 'the value for all debian'}
        #     [:centos, :redhat, :fedora] => {:default => "value for all EL variants"}
        #     :ubuntu => { :default => "default for ubuntu", '10.04' => "value for 10.04 only"},
        #     :default => "the default when nothing else matches"
        #   }
        # * platforms can be specified as Symbols or Strings
        # * multiple platforms can be grouped by using an Array as the key
        # * values for platforms need to be Hashes of the form:
        #   {platform_version => value_for_that_version}
        # * the exception to the above is the default value, which is given as
        #   :default => default_value
        def initialize(platform_hash)
          @values = {}
          platform_hash.each { |platforms, value| set(platforms, value)}
        end

        def value_for_node(node)
          platform, version = node[:platform].to_s, node[:platform_version].to_s
          if @values.key?(platform) && @values[platform].key?(version)
            @values[platform][version]
          elsif @values.key?(platform) && @values[platform].key?("default")
            @values[platform]["default"]
          elsif @values.key?("default")
            @values["default"]
          else
            nil
          end
        end

        private

        def set(platforms, value)
          if platforms.to_s == 'default'
            @values["default"] = value
          else
            assert_valid_platform_values!(platforms, value)
            Array(platforms).each { |platform| @values[platform.to_s] = format_values(value)}
            value
          end
        end

        def format_values(hash)
          formatted_array = flatten_one_level(hash.map { |key, value| [key.to_s, value]})
          Hash[*formatted_array]
        end

        def flatten_one_level(array)
          array.inject([]) do |flatter_array, values|
            Array(values).each {|value| flatter_array << value }
            flatter_array
          end
        end


        def assert_valid_platform_values!(platforms, value)
          unless value.kind_of?(Hash)
            msg = "platform dependent values must be specified in the format :platform => {:version => value} "
            msg << "you gave a value #{value.inspect} for platform(s) #{platforms}"
            raise ArgumentError, msg
          end
        end
      end

      # Given a hash similar to the one we use for Platforms, select a value from the hash.  Supports
      # per platform defaults, along with a single base default. Arrays may be passed as hash keys and
      # will be expanded.
      #
      # === Parameters
      # platform_hash:: A platform-style hash.
      #
      # === Returns
      # value:: Whatever the most specific value of the hash is.
      def value_for_platform(platform_hash)
        PlatformDependentValue.new(platform_hash).value_for_node(node)
      end

      # Given a list of platforms, returns true if the current recipe is being run on a node with
      # that platform, false otherwise.
      #
      # === Parameters
      # args:: A list of platforms
      #
      # === Returns
      # true:: If the current platform is in the list
      # false:: If the current platform is not in the list
      def platform?(*args)
        has_platform = false
  
        args.flatten.each do |platform|
          has_platform = true if platform == node[:platform]
        end
  
        has_platform
      end

      def search(*args, &block)
        # If you pass a block, or have at least the start argument, do raw result parsing
        # 
        # Otherwise, do the iteration for the end user
        if Kernel.block_given? || args.length >= 4 
          Chef::Search::Query.new.search(*args, &block)
        else 
          results = Array.new
          Chef::Search::Query.new.search(*args) do |o|
            results << o 
          end
          results
        end
      end

      def data_bag(bag)
        rbag = Chef::DataBag.load(bag)
        rbag.keys
      end

      def data_bag_item(bag, item)
        Chef::DataBagItem.load(bag, item)
      end

    end
  end
end
