#
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Copyright:: Copyright (c) 2010 VMware, Inc.
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

require 'chef/provider'
require 'chef/mixin/command'
require 'chef/resource/env'

class Chef
  class Provider
    class Env < Chef::Provider
      include Chef::Mixin::Command
      attr_accessor :key_exists

      def initialize(new_resource, run_context)
        super
        @key_exists = true
      end

      def load_current_resource
        @current_resource = Chef::Resource::Env.new(@new_resource.name)
        @current_resource.key_name(@new_resource.key_name)

        if env_key_exists(@new_resource.key_name)
          @current_resource.value(env_value(@new_resource.key_name))
        else
          @key_exists = false
          Chef::Log.debug("#{@new_resource}: key does not exist")
        end

        @current_resource
      end

      def env_value(key_name)
        raise Chef::Exceptions::Env, "#{@new_resource} - #{self.to_s} provider does not implement env_value!"
      end

      def env_key_exists(key_name)
        env_value(key_name) ? true : false
      end

      # Check to see if value needs any changes
      #
      # ==== Returns
      # <true>:: If a change is required
      # <false>:: If a change is not required
      def compare_value
        if @new_resource.delim
          #e.g. check for existing value within PATH
          not @current_resource.value.split(@new_resource.delim).any? do |val|
            val == @new_resource.value
          end
        else
          @new_resource.value != @current_resource.value
        end
      end

      def action_create
        if @key_exists
          if compare_value
            modify_env
            Chef::Log.info("Altered #{@new_resource}")
            @new_resource.updated_by_last_action(true)
          end
        else
          create_env
          Chef::Log.debug("Created #{@new_resource}")
          @new_resource.updated_by_last_action(true)
        end
      end

      #e.g. delete a PATH element
      #
      # ==== Returns
      # <true>:: If we handled the element case and caller should not delete the key
      # <false>:: Caller should delete the key, either no :delim was specific or value was empty
      #           after we removed the element.
      def delete_element
        return false unless @new_resource.delim #no delim: delete the key
        if compare_value
          Chef::Log.debug("#{@new_resource}: element '#{@new_resource.value}' does not exist")
          return true #do not delete the key
        else
          new_value =
            @current_resource.value.split(@new_resource.delim).select { |item|
            item != @new_resource.value
          }.join(@new_resource.delim)

          if new_value.empty?
            return false #nothing left here, delete the key
          else
            old_value = @new_resource.value(new_value)
            create_env
            Chef::Log.debug("Deleted #{old_value} element")
            @new_resource.updated_by_last_action(true)
            return true #we removed the element and updated; do not delete the key
          end
        end
      end

      def action_delete
        if @key_exists && !delete_element
          delete_env
          Chef::Log.debug("Deleted #{@new_resource}")
          @new_resource.updated_by_last_action(true)
        end
      end

      def action_modify
        if @key_exists
          if compare_value
            modify_env
            @new_resource.updated_by_last_action(true)
            Chef::Log.info("Modified #{@new_resource}")
          end
        else
          raise Chef::Exceptions::Env, "Cannot modify #{@new_resource} - key does not exist!"
        end
      end

      def create_env
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :#{@new_resource.action}"
      end

      def delete_env
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :delete"
      end

      def modify_env
        if @new_resource.delim
          #e.g. add to PATH
          @new_resource.value << @new_resource.delim << @current_resource.value
        end
        create_env
      end
     end
  end
end
