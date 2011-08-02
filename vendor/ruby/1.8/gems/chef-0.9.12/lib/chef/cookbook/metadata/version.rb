#
# Author:: AJ Christensen (<aj@opscode.com>)
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

require 'chef/cookbook_version'
require 'chef/cookbook/metadata'

class Chef::Cookbook::Metadata
  class Version
    include Comparable

    attr_accessor :major,
                  :minor,
                  :patch

    def initialize(str="")
      @major, @minor, @patch = _parse(str)
    end

    def _parse(str="")
      @major, @minor, @patch = case str.to_s
        when /^(\d+)\.(\d+)\.(\d+)$/
          [ $1.to_i, $2.to_i, $3.to_i ]
        when /^(\d+)\.(\d+)$/
          [ $1.to_i, $2.to_i, 0 ]
        else
          raise "Metadata version '#{str.to_s}' does not match 'x.y.z' or 'x.y'"
      end
    end

    def inspect
      "#{@major}.#{@minor}.#{@patch}"
    end

    def to_s
      "#{@major}.#{@minor}.#{@patch}"
    end

    def <=>(v)
      major, minor, patch = (
        [ :major, :minor, :patch ].collect do |method|
          self.send(method) <=> v.send(method)
        end
      )

      Chef::Log.debug "(#{self.to_s}/#{v.to_s}) major,minor,patch: #{[major,minor,patch].join(',')}"

      # all these returns feels like C, surely there is a better way!

      if major == 0 && minor == 0 && patch == 0
        comp = 0
      end

      if major == 1
        comp = 1
      end

      if major == 0 && minor == 1 && patch == -1
        comp = 1
      end

      if minor == 1 && major == 0 && patch == 0
        comp = 1
      end

      if patch == 1 && major == 0 && minor == 0
        comp = 1
      end

      return (comp || -1)
    end
  end
end
