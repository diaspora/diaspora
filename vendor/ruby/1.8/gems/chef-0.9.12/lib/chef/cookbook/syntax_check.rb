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
#

require 'chef/checksum_cache'
require 'chef/mixin/shell_out'

class Chef
  class Cookbook
    # == Chef::Cookbook::SyntaxCheck
    # Encapsulates the process of validating the ruby syntax of files in Chef
    # cookbooks.
    class SyntaxCheck
      include Chef::Mixin::ShellOut

      attr_reader :cookbook_path

      # Creates a new SyntaxCheck given the +cookbook_name+ and a +cookbook_path+.
      # If no +cookbook_path+ is given, +Chef::Config.cookbook_path+ is used.
      def self.for_cookbook(cookbook_name, cookbook_path=nil)
        cookbook_path ||= Chef::Config.cookbook_path
        unless cookbook_path
          raise ArgumentError, "Cannot find cookbook #{cookbook_name} unless Chef::Config.cookbook_path is set or an explicit cookbook path is given"
        end
        new(File.join(cookbook_path, cookbook_name.to_s))
      end

      # Create a new SyntaxCheck object
      # === Arguments
      # cookbook_path::: the (on disk) path to the cookbook
      def initialize(cookbook_path)
        @cookbook_path = cookbook_path
      end

      def cache
        Chef::ChecksumCache.instance
      end

      def ruby_files
        Dir[File.join(cookbook_path, '**', '*.rb')]
      end

      def untested_ruby_files
        ruby_files.reject do |file|
          if validated?(file)
            Chef::Log.debug("ruby file #{file} is unchanged, skipping syntax check")
            true
          else
            false
          end
        end
      end

      def template_files
        Dir[File.join(cookbook_path, '**', '*.erb')]
      end

      def untested_template_files
        template_files.reject do |file| 
          if validated?(file)
            Chef::Log.debug("template #{file} is unchanged, skipping syntax check")
            true
          else
            false
          end
        end
      end

      def validated?(file)
        !!cache.lookup_checksum(cache_key(file), File.stat(file))
      end

      def validated(file)
        cache.generate_checksum(cache_key(file), file, File.stat(file))
      end

      def cache_key(file)
        @cache_keys ||= {}
        @cache_keys[file] ||= cache.generate_key(file, "chef-test")
      end

      def validate_ruby_files
        untested_ruby_files.each do |ruby_file|
          return false unless validate_ruby_file(ruby_file)
          validated(ruby_file)
        end
      end

      def validate_templates
        untested_template_files.each do |template|
          return false unless validate_template(template)
          validated(template)
        end
      end

      def validate_template(erb_file)
        Chef::Log.debug("Testing template #{erb_file} for syntax errors...")
        result = shell_out("sh -c 'erubis -x #{erb_file} | ruby -c'")
        result.error!
        true
      rescue Chef::Exceptions::ShellCommandFailed
        file_relative_path = erb_file[/^#{Regexp.escape(cookbook_path+File::Separator)}(.*)/, 1]
        Chef::Log.fatal("Erb template #{file_relative_path} has a syntax error:")
        result.stderr.each_line { |l| Chef::Log.fatal(l.chomp) }
        false
      end
      
      def validate_ruby_file(ruby_file)
        Chef::Log.debug("Testing #{ruby_file} for syntax errors...")
        result = shell_out("ruby -c #{ruby_file}")
        result.error!
        true
      rescue Chef::Exceptions::ShellCommandFailed
        file_relative_path = ruby_file[/^#{Regexp.escape(cookbook_path+File::Separator)}(.*)/, 1]
        Chef::Log.fatal("Cookbook file #{file_relative_path} has a ruby syntax error:")
        result.stderr.each_line { |l| Chef::Log.fatal(l.chomp) }
        false
      end
      
    end
  end
end