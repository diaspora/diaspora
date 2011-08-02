#
# Author:: Doug MacEachern <dougm@vmware.com>
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

require "sigar"

sigar = Sigar.new

provides "memory"

memory Mash.new
memory[:swap] = Mash.new

mem = sigar.mem
swap = sigar.swap

memory[:total] = (mem.total / 1024).to_s + "kB"
memory[:free] = (mem.free / 1024).to_s + "kB"
memory[:used] = (mem.used / 1024).to_s + "kB"
memory[:swap][:total] = (swap.total / 1024).to_s + "kB"
memory[:swap][:free] = (swap.free / 1024).to_s + "kB"
memory[:swap][:used] = (swap.used / 1024).to_s + "kB"
