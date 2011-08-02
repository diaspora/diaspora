#
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Copyright:: Copyright (c) 2010 VMware, Inc.
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
#requires: gem install windows-pr
require 'windows/api'
require 'windows/error'
require 'windows/handle'
require 'windows/unicode'
require 'windows/msvcrt/buffer'
require 'windows/msvcrt/string'
require 'windows/network/management'

class Chef
  class Util
    class Windows
      protected

      include ::Windows::Error
      include ::Windows::Unicode
      include ::Windows::MSVCRT::Buffer
      include ::Windows::MSVCRT::String
      include ::Windows::Network::Management

      PTR_SIZE = 4 #XXX 64-bit

      def lpwstr_to_s(buffer, offset)
        str = 0.chr * (256 * 2) #XXX unhardcode this length (*2 for WCHAR)
        wcscpy str, buffer[offset*PTR_SIZE,PTR_SIZE].unpack('L')[0]
        wide_to_multi str
      end

      def dword_to_i(buffer, offset)
        buffer[offset*PTR_SIZE,PTR_SIZE].unpack('i')[0] || 0
      end

      #return pointer for use with pack('L')
      def str_to_ptr(v)
        [v].pack('p*').unpack('L')[0]
      end
    end
  end
end
