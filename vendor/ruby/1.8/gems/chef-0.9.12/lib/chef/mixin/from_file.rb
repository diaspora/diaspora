#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
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

class Chef
  module Mixin
    module FromFile
    
      # Loads a given ruby file, and runs instance_eval against it in the context of the current 
      # object.  
      #
      # Raises an IOError if the file cannot be found, or is not readable.
      def from_file(filename)
        if File.exists?(filename) && File.readable?(filename)
          self.instance_eval(IO.read(filename), filename, 1)
        else
          raise IOError, "Cannot open or read #{filename}!"
        end
      end

      # Loads a given ruby file, and runs class_eval against it in the context of the current 
      # object.
      #
      # Raises an IOError if the file cannot be found, or is not readable.
      def class_from_file(filename)
        if File.exists?(filename) && File.readable?(filename)
          self.class_eval(IO.read(filename), filename, 1)
        else
          raise IOError, "Cannot open or read #{filename}!"
        end
      end

    end
  end
end
