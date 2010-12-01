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

# NetBSD provides some cpu information via sysctl, and a little via dmesg.boot
# unlike OpenBSD and FreeBSD, NetBSD does not provide information about the
# available instruction set
# cpu0 at mainbus0 apid 0: Intel 686-class, 2134MHz, id 0x6f6

File.open("/var/run/dmesg.boot").each do |line|
  case line
    when /cpu[\d\w\s]+:\s([\w\s\-]+),\s+(\w+),/
      cpuinfo[:model_name] = $1
      cpuinfo[:mhz] = $2.gsub(/mhz/i, "")
  end
end

flags = []
popen4("dmidecode") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    if line =~ /^\s+([A-Z\d-]+)\s+\([\w\s-]+\)$/
      flags << $1.downcase
    end
  end
end

cpuinfo[:flags] = flags unless flags.empty?

cpu cpuinfo
