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

# == String (Patch)
# On ruby 1.9, Strings are aware of multibyte characters, so +size+ and +length+
# give the actual number of characters. In Chef::REST, we need the bytesize
# so we can correctly set the Content-Length headers, but ruby 1.8.6 and lower
# don't define String#bytesize. Monkey patching time!
class String
  unless method_defined?(:bytesize)
    alias :bytesize :size
  end
end
