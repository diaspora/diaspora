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

if RUBY_VERSION < "1.8.6" || RUBY_PLATFORM =~ /mswin|mingw32|windows/
  class Dir 
    class << self 
      alias_method :glob_, :glob 
      # Adds a Dir.glob to Ruby 1.8.5, for compat
      def glob(pattern, flags=0)
        raise ArgumentError unless (
          !pattern.nil? and (
            pattern.is_a? Array and !pattern.empty?
          ) or pattern.is_a? String
        )
        pattern.gsub!(/\\/, "/") if RUBY_PLATFORM =~ /mswin|mingw32|windows/
        [pattern].flatten.inject([]) { |r, p| r + glob_(p, flags) }
      end
      alias_method :[], :glob 
    end 
  end 
end 
