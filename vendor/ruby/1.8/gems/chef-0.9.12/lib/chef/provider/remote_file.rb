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

require 'chef/provider/file'
require 'chef/rest'
require 'chef/mixin/find_preferred_file'
require 'uri'
require 'tempfile'
require 'net/https'

class Chef
  class Provider
    class RemoteFile < Chef::Provider::File

      include Chef::Mixin::FindPreferredFile

      def load_current_resource
        super
        @current_resource.checksum(checksum(@current_resource.path)) if ::File.exist?(@current_resource.path)
      end

      def action_create
        Chef::Log.debug("Checking #{@new_resource} for changes")

        if current_resource_matches_target_checksum?
          Chef::Log.debug("File #{@new_resource} checksum matches target checksum (#{@new_resource.checksum}), not updating")
        else
          Chef::REST.new(@new_resource.source, nil, nil).fetch(@new_resource.source) do |raw_file|
            if matches_current_checksum?(raw_file)
              Chef::Log.debug "#{@new_resource}: Target and Source checksums are the same, taking no action"
            else
              backup_new_resource
              Chef::Log.debug "copying remote file from origin #{raw_file.path} to destination #{@new_resource.path}"
              FileUtils.cp raw_file.path, @new_resource.path
              @new_resource.updated_by_last_action(true)
            end
          end
        end
        enforce_ownership_and_permissions

        @new_resource.updated_by_last_action?
      end

      def action_create_if_missing
        if ::File.exists?(@new_resource.path)
          Chef::Log.debug("File #{@new_resource.path} exists, taking no action.")
        else
          action_create
        end
      end

      def enforce_ownership_and_permissions
        set_owner if @new_resource.owner
        set_group if @new_resource.group
        set_mode  if @new_resource.mode
      end

      def current_resource_matches_target_checksum?
        @new_resource.checksum && @current_resource.checksum && @current_resource.checksum =~ /^#{Regexp.escape(@new_resource.checksum)}/
      end

      def matches_current_checksum?(candidate_file)
        Chef::Log.debug "#{@new_resource}: Checking for file existence of #{@new_resource.path}"
        if ::File.exists?(@new_resource.path)
          Chef::Log.debug "#{@new_resource}: File exists at #{@new_resource.path}"
          @new_resource.checksum(checksum(candidate_file.path))
          Chef::Log.debug "#{@new_resource}: Target checksum: #{@current_resource.checksum}"
          Chef::Log.debug "#{@new_resource}: Source checksum: #{@new_resource.checksum}"

          @new_resource.checksum == @current_resource.checksum
        else
          Chef::Log.info "#{@new_resource}: Creating #{@new_resource.path}"
          false
        end
      end

      def backup_new_resource
        if ::File.exists?(@new_resource.path)
          Chef::Log.debug "#{@new_resource}: checksum changed from #{@current_resource.checksum} to #{@new_resource.checksum}"
          Chef::Log.info "#{@new_resource}: Updating #{@new_resource.path}"
          backup @new_resource.path
        end
      end

      def source_file(source, current_checksum, &block)
        if absolute_uri?(source)
          fetch_from_uri(source, &block)
        elsif !Chef::Config[:solo]
          fetch_from_chef_server(source, current_checksum, &block)
        else
          fetch_from_local_cookbook(source, &block)
        end
      end

      private

      def absolute_uri?(source)
        URI.parse(source).absolute?
      rescue URI::InvalidURIError
        false
      end

    end
  end
end
