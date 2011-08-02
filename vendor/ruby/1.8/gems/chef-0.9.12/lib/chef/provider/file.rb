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

require 'chef/config'
require 'chef/log'
require 'chef/resource/file'
require 'chef/mixin/checksum'
require 'chef/provider'
require 'etc'
require 'fileutils'

class Chef
  class Provider
    class File < Chef::Provider
      include Chef::Mixin::Checksum

      def negative_complement(big)
        if big > 1073741823 # Fixnum max
          big -= (2**32) # diminished radix wrap to negative
        end
        big
      end

      def octal_mode(mode)
        ((mode.respond_to?(:oct) ? mode.oct : mode.to_i) & 007777)
      end

      private :negative_complement, :octal_mode

      def load_current_resource
        @current_resource = Chef::Resource::File.new(@new_resource.name)
        @new_resource.path.gsub!(/\\/, "/") # for Windows
        @current_resource.path(@new_resource.path)
        if ::File.exist?(@current_resource.path) && ::File.readable?(@current_resource.path)
          cstats = ::File.stat(@current_resource.path)
          @current_resource.owner(cstats.uid)
          @current_resource.group(cstats.gid)
          @current_resource.mode(octal_mode(cstats.mode))
        end
        @current_resource
      end

      # Compare the content of a file.  Returns true if they are the same, false if they are not.
      def compare_content
        checksum(@current_resource.path) == new_resource_content_checksum
      end

      # Set the content of the file, assuming it is not set correctly already.
      def set_content
        unless compare_content
          Chef::Log.info("Setting content for #{@new_resource}")
          backup @new_resource.path if ::File.exists?(@new_resource.path)
          ::File.open(@new_resource.path, "w") {|f| f.write @new_resource.content }
          @new_resource.updated_by_last_action(true)
        end
      end

      # Compare the ownership of a file.  Returns true if they are the same, false if they are not.
      def compare_owner
        return false if @new_resource.owner.nil?

        @set_user_id = case @new_resource.owner
                       when /^\d+$/, Integer
                         @new_resource.owner.to_i
                       else
                         # This raises an ArgumentError if you can't find the user
                         Etc.getpwnam(@new_resource.owner).uid
                       end

        @set_user_id == @current_resource.owner
      end

      # Set the ownership on the file, assuming it is not set correctly already.
      def set_owner
        unless compare_owner
          Chef::Log.info("Setting owner to #{@set_user_id} for #{@new_resource}")
          @set_user_id = negative_complement(@set_user_id)
          ::File.chown(@set_user_id, nil, @new_resource.path)
          @new_resource.updated_by_last_action(true)
        end
      end

      # Compares the group of a file.  Returns true if they are the same, false if they are not.
      def compare_group
        return false if @new_resource.group.nil?

        @set_group_id = case @new_resource.group
                        when /^\d+$/, Integer
                          @new_resource.group.to_i
                        else
                          Etc.getgrnam(@new_resource.group).gid
                        end

        @set_group_id == @current_resource.group
      end

      def set_group
        unless compare_group
          Chef::Log.info("Setting group to #{@set_group_id} for #{@new_resource}")
          @set_group_id = negative_complement(@set_group_id)
          ::File.chown(nil, @set_group_id, @new_resource.path)
          @new_resource.updated_by_last_action(true)
        end
      end

      def compare_mode
        case @new_resource.mode
        when /^\d+$/, Integer
          octal_mode(@new_resource.mode) == octal_mode(@current_resource.mode)
        else
          false
        end
      end

      def set_mode
        unless compare_mode && @new_resource.mode != nil
          Chef::Log.info("Setting mode to #{sprintf("%o" % octal_mode(@new_resource.mode))} for #{@new_resource}")
          # CHEF-174, bad mojo around treating integers as octal.  If a string is passed, we try to do the "right" thing
          ::File.chmod(octal_mode(@new_resource.mode), @new_resource.path)
          @new_resource.updated_by_last_action(true)
        end
      end

      def action_create
        unless ::File.exists?(@new_resource.path)
          Chef::Log.info("Creating #{@new_resource} at #{@new_resource.path}")
          ::File.open(@new_resource.path, "w+") {|f| f.write @new_resource.content }
          @new_resource.updated_by_last_action(true)
        else
          set_content unless @new_resource.content.nil?
        end
        set_owner unless @new_resource.owner.nil?
        set_group unless @new_resource.group.nil?
        set_mode unless @new_resource.mode.nil?
      end

      def action_create_if_missing
        action_create
      end

      def action_delete
        if ::File.exists?(@new_resource.path)
          if ::File.writable?(@new_resource.path)
            backup unless ::File.symlink?(@new_resource.path)
            Chef::Log.info("Deleting #{@new_resource} at #{@new_resource.path}")
            ::File.delete(@new_resource.path)
            @new_resource.updated_by_last_action(true)
          else
            raise "Cannot delete #{@new_resource} at #{@new_resource_path}!"
          end
        end
      end

      def action_touch
        action_create
        time = Time.now
        Chef::Log.info("Updating #{@new_resource} with new atime/mtime of #{time}")
        ::File.utime(time, time, @new_resource.path)
        @new_resource.updated_by_last_action(true)
      end

      def backup(file=nil)
        file ||= @new_resource.path
        if @new_resource.backup != false && @new_resource.backup > 0 && ::File.exist?(file)
          time = Time.now
          savetime = time.strftime("%Y%m%d%H%M%S")
          backup_filename = "#{@new_resource.path}.chef-#{savetime}"
          backup_filename = backup_filename.sub(/^([A-Za-z]:)/, "") #strip drive letter on Windows
          # if :file_backup_path is nil, we fallback to the old behavior of
          # keeping the backup in the same directory. We also need to to_s it
          # so we don't get a type error around implicit to_str conversions.
          prefix = Chef::Config[:file_backup_path].to_s
          backup_path = ::File.join(prefix, backup_filename)
          FileUtils.mkdir_p(::File.dirname(backup_path)) if Chef::Config[:file_backup_path]
          Chef::Log.info("Backing up #{@new_resource} to #{backup_path}")
          FileUtils.cp(file, backup_path, :preserve => true)

          # Clean up after the number of backups
          slice_number = @new_resource.backup
          backup_files = Dir[::File.join(prefix, ".#{@new_resource.path}.chef-*")].sort { |a,b| b <=> a }
          if backup_files.length >= @new_resource.backup
            remainder = backup_files.slice(slice_number..-1)
            remainder.each do |backup_to_delete|
              Chef::Log.info("Removing backup of #{@new_resource} at #{backup_to_delete}")
              FileUtils.rm(backup_to_delete)
            end
          end
        end
      end

      private

      def new_resource_content_checksum
        @new_resource.content && Digest::SHA2.hexdigest(@new_resource.content)
      end
    end
  end
end
