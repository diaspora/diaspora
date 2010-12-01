# encoding: UTF-8

# --
# Copyright (C) 2008-2010 10gen Inc.
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
# ++
module Mongo
  # Simple class for comparing server versions.
  class ServerVersion
    include Comparable

    def initialize(version)
      @version = version
    end

    # Implements comparable.
    def <=>(new)
      local, new  = self.to_a, to_array(new)
      for n in 0...local.size do
        break if elements_include_mods?(local[n], new[n])
        if local[n] < new[n].to_i
          result = -1
          break;
        elsif local[n] > new[n].to_i
          result = 1
          break;
        end
      end
      result || 0
    end

    # Return an array representation of this server version.
    def to_a
      to_array(@version)
    end

    # Return a string representation of this server version.
    def to_s
      @version
    end

    private

    # Returns true if any elements include mod symbols (-, +)
    def elements_include_mods?(*elements)
      elements.any? { |n| n =~ /[\-\+]/ }
    end

    # Converts argument to an array of integers,
    # appending any mods as the final element.
    def to_array(version)
      array = version.split(".").map {|n| (n =~ /^\d+$/) ? n.to_i : n }
      if array.last =~ /(\d+)([\-\+])/
        array[array.length-1] = $1.to_i
        array << $2
      end
      array
    end
  end
end
