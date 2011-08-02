#
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

require 'mixlib/authentication'

module Mixlib
  module Authentication
    class Digester
      
      class << self
        
        def hash_file(f)
          digester = Digest::SHA1.new
          buf = ""
          while f.read(16384, buf)
            digester.update buf
          end
          ::Base64.encode64(digester.digest).chomp
        end

        # Digests a string, base64's and chomps the end
        # 
        # ====Parameters
        # 
        def hash_string(str)
          ::Base64.encode64(Digest::SHA1.digest(str)).chomp
        end
        
      end
      
    end
  end
end
