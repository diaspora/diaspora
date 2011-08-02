#
# Author:: Mathieu Sauve-Frankel <msf@kisoku.net>
# Copyright:: Copyright (c) 2009 Mathieu Sauve-Frankel
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

provides 'cpu'

cpuinfo = Mash.new

# OpenBSD provides most cpu information via sysctl, the only thing we need to 
# to scrape from dmesg.boot is the cpu feature list. 
# cpu0: FPU,V86,DE,PSE,TSC,MSR,MCE,CX8,SEP,MTRR,PGE,MCA,CMOV,PAT,CFLUSH,DS,ACPI,MMX,FXSR,SSE,SSE2,SS,TM,SBF,EST,TM2

File.open("/var/run/dmesg.boot").each do |line|
  case line
    when /cpu\d+:\s+([A-Z]+$|[A-Z]+,.*$)/
      cpuinfo["flags"] = $1.downcase.split(',')
  end
end

cpuinfo[:model_name] = from("sysctl -n hw.model")
cpuinfo[:total] = from("sysctl -n hw.ncpu")
cpuinfo[:mhz] = from("sysctl -n hw.cpuspeed")

cpu cpuinfo
