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

provides "os", "os_version"

require 'rbconfig'

require_plugin 'kernel'

case ::Config::CONFIG['host_os']
when /aix(.+)$/
  os "aix"
when /darwin(.+)$/
  os "darwin"
when /hpux(.+)$/
  os "hpux"
when /linux/
  os "linux"
when /freebsd(.+)$/
  os "freebsd"
when /openbsd(.+)$/
  os "openbsd"
when /netbsd(.+)$/
  os "netbsd"
when /solaris2\.([\d]+)/
  os "solaris2"
when /mswin|mingw32|windows/
  # After long discussion in IRC the "powers that be" have come to a concensus
  # that there is no other Windows platforms exist that were not based on the
  # Windows_NT kernel, so we herby decree that "windows" will refer to all
  # platforms built upon the Windows_NT kernel and have access to win32 or win64
  # subsystems.
  os "windows"
else
  os ::Config::CONFIG['host_os']
end

os_version kernel[:release]
