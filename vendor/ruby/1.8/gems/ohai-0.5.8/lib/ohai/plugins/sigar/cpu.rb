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

provides "cpu"

cpuinfo = Mash.new
ix = 0

sigar.cpu_info_list.each do |info|
  current_cpu = ix.to_s
  ix += 1
  cpuinfo[current_cpu] = Mash.new
  cpuinfo[current_cpu]["vendor_id"] = info.vendor
  cpuinfo[current_cpu]["model"] = info.model
  cpuinfo[current_cpu]["mhz"] = info.mhz.to_s
  cpuinfo[current_cpu]["cache_size"] = info.cache_size.to_s
  cpuinfo[:total] = info.total_cores
  cpuinfo[:real] = info.total_sockets
end

cpu cpuinfo
