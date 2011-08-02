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

provides "cpu"

cpuinfo = Mash.new
real_cpu = Mash.new
cpu_number = 0
current_cpu = nil

File.open("/proc/cpuinfo").each do |line|
  case line
  when /processor\s+:\s(.+)/
    cpuinfo[$1] = Mash.new
    current_cpu = $1
    cpu_number += 1
  when /vendor_id\s+:\s(.+)/
    cpuinfo[current_cpu]["vendor_id"] = $1
  when /cpu family\s+:\s(.+)/
    cpuinfo[current_cpu]["family"] = $1
  when /model\s+:\s(.+)/
    cpuinfo[current_cpu]["model"] = $1
  when /stepping\s+:\s(.+)/
    cpuinfo[current_cpu]["stepping"] = $1
  when /physical id\s+:\s(.+)/
    cpuinfo[current_cpu]["physical_id"] = $1
    real_cpu[$1] = true
  when /core id\s+:\s(.+)/
    cpuinfo[current_cpu]["core_id"] = $1
  when /cpu cores\s+:\s(.+)/
    cpuinfo[current_cpu]["cores"] = $1
  when /model name\s+:\s(.+)/
    cpuinfo[current_cpu]["model_name"] = $1
  when /cpu MHz\s+:\s(.+)/
    cpuinfo[current_cpu]["mhz"] = $1
  when /cache size\s+:\s(.+)/
    cpuinfo[current_cpu]["cache_size"] = $1
  when /flags\s+:\s(.+)/
    cpuinfo[current_cpu]["flags"] = $1.split(' ')
  end
end

cpu cpuinfo
cpu[:total] = cpu_number
cpu[:real] = real_cpu.keys.length