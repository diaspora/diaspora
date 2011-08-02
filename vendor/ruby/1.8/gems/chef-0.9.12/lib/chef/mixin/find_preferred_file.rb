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

require 'chef/cookbook_loader'

class Chef
  module Mixin
    module FindPreferredFile

      def load_cookbook_files(cookbook_id, file_type)
        unless file_type == :remote_file || file_type == :template
          raise ArgumentError, "You must supply :remote_file or :template as the file_type"
        end
        
        cl = Chef::CookbookLoader.new
        cookbook = cl[cookbook_id]
        raise NotFound unless cookbook

        files = Hash.new
        
        cookbook_method = nil
        
        case file_type
        when :remote_file
          cookbook_method = :remote_files
        when :template
          cookbook_method = :template_files
        end
                
        cookbook.send(cookbook_method).each do |rf|
          full = File.expand_path(rf)
          name = File.basename(full)
          case file_type
          when :remote_file
            rf =~ /^.+#{Regexp.escape(cookbook_id)}[\\|\/]files[\\|\/](.+?)[\\|\/]#{Regexp.escape(name)}/
          when :template
            rf =~ /^.+#{Regexp.escape(cookbook_id)}[\\|\/]templates[\\|\/](.+?)[\\|\/]#{Regexp.escape(name)}/
          end
          singlecopy = $1
          files[full] = {
            :name => name,
            :singlecopy => singlecopy,
            :file => full,
          }
        end
        Chef::Log.debug("Preferred #{file_type} list: #{files.inspect}")
        
        files
      end

      def find_preferred_file(cookbook_id, file_type, file_name, fqdn, platform, version)
        file_list = load_cookbook_files(cookbook_id, file_type)
        
        preferences = [
          File.join("host-#{fqdn}", "#{file_name}"),
          File.join("#{platform}-#{version}", "#{file_name}"),
          File.join("#{platform}", "#{file_name}"),
          File.join("default", "#{file_name}")
        ]
        
        file_list_str = file_list.keys.join("\n")
        Chef::Log.debug("Searching for preferred file in\n#{file_list_str}")
        
        preferences.each do |pref|
          Chef::Log.debug("Looking for #{pref}")
          matcher = /^(.+#{Regexp.escape(pref)})$/
          if match = matcher.match(file_list_str)
            return match[1]
          end
        end
        
        raise Chef::Exceptions::FileNotFound, "Cannot find a preferred file for #{file_name}!"
      end
      
    end
  end
end
