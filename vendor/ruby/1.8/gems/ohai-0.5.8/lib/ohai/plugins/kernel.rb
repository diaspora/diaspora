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

provides "kernel"

require_plugin 'ruby'

kernel Mash.new
case languages[:ruby][:host_os]
when /mswin|mingw32|windows/
  require_plugin "windows::kernel"
else
  kernel[:name] = from("uname -s")
  kernel[:release] = from("uname -r")
  kernel[:version] = from("uname -v")
  kernel[:machine] = from("uname -m")
  kernel[:modules] = Mash.new
end
