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

require 'chef/mixin/params_validate'
require 'chef/mixin/create_path'
require 'chef/exceptions'
require 'json'
require 'fileutils'

class Chef
  class FileCache
    class << self
      include Chef::Mixin::ParamsValidate
      include Chef::Mixin::CreatePath

      # Write a file to the File Cache.
      #
      # === Parameters
      # path<String>:: The path to the file you want to put in the cache - should
      #   be relative to file_cache_path
      # contents<String>:: A string with the contents you want written to the file
      #
      # === Returns
      # true
      def store(path, contents)
        validate(
          {
            :path => path,
            :contents => contents
          },
          {
            :path => { :kind_of => String },
            :contents => { :kind_of => String },
          }
        )

        file_path_array = File.split(path)
        file_name = file_path_array.pop
        cache_path = create_cache_path(File.join(file_path_array))
        File.open(File.join(cache_path, file_name), "w") do |io|
          io.print(contents)
        end
        true
      end

      # Move a file into the cache.  Useful with the REST raw file output.
      #
      # === Parameters
      # file<String>:: The path to the file you want in the cache
      # path<String>:: The relative name you want the new file to use
      def move_to(file, path)
        validate(
          {
            :file => file,
            :path => path
          },
          {
            :file => { :kind_of => String },
            :path => { :kind_of => String },
          }
        )

        file_path_array = File.split(path)
        file_name = file_path_array.pop
        if File.exists?(file) && File.writable?(file)
          FileUtils.mv(
            file,
            File.join(create_cache_path(File.join(file_path_array), true), file_name)
          )
        else
          raise RuntimeError, "Cannot move #{file} to #{path}!"
        end
      end

      # Read a file from the File Cache
      #
      # === Parameters
      # path<String>:: The path to the file you want to load - should
      #   be relative to file_cache_path
      # read<True/False>:: Whether to return the file contents, or the path.
      #   Defaults to true.
      #
      # === Returns
      # String:: A string with the file contents, or the path to the file.
      #
      # === Raises
      # Chef::Exceptions::FileNotFound:: If it cannot find the file in the cache
      def load(path, read=true)
        validate(
          {
            :path => path
          },
          {
            :path => { :kind_of => String }
          }
        )
        cache_path = create_cache_path(path, false)
        raise Chef::Exceptions::FileNotFound, "Cannot find #{cache_path} for #{path}!" unless File.exists?(cache_path)
        if read
          File.read(cache_path)
        else
          cache_path
        end
      end

      # Delete a file from the File Cache
      #
      # === Parameters
      # path<String>:: The path to the file you want to delete - should
      #   be relative to file_cache_path
      #
      # === Returns
      # true
      def delete(path)
        validate(
          {
            :path => path
          },
          {
            :path => { :kind_of => String },
          }
        )
        cache_path = create_cache_path(path, false)
        if File.exists?(cache_path)
          File.unlink(cache_path)
        end
        true
      end

      # List all the files in the Cache
      #
      # === Returns
      # Array:: An array of files in the cache, suitable for use with load, delete and store
      def list
        find("**#{File::Separator}*")
      end

      ##
      # Find files in the cache by +glob_pattern+
      # === Returns
      # [String] - An array of file cache keys matching the glob
      def find(glob_pattern)
        keys = Array.new
        Dir[File.join(file_cache_path, glob_pattern)].each do |f|
          if File.file?(f)
            keys << f[/^#{Regexp.escape(Dir[file_cache_path].first) + File::Separator}(.+)/, 1]
          end
        end
        keys
      end

      # Whether or not this file exists in the Cache
      #
      # === Parameters
      # path:: The path to the file you want to check - is relative
      #   to file_cache_path
      #
      # === Returns
      # True:: If the file exists
      # False:: If it does not
      def has_key?(path)
        validate(
          {
            :path => path
          },
          {
            :path => { :kind_of => String },
          }
        )
        full_path = create_cache_path(path, false)
        if File.exists?(full_path)
          true
        else
          false
        end
      end

      # Create a full path to a given file in the cache. By default,
      # also creates the path if it does not exist.
      #
      # === Parameters
      # path:: The path to create, relative to file_cache_path
      # create_if_missing:: True by default - whether to create the path if it does not exist
      #
      # === Returns
      # String:: The fully expanded path
      def create_cache_path(path, create_if_missing=true)
        cache_dir = File.expand_path(File.join(file_cache_path, path))
        if create_if_missing
          create_path(cache_dir)
        else
          cache_dir
        end
      end

      private

      def file_cache_path
        Chef::Config[:file_cache_path]
      end

    end
  end
end
