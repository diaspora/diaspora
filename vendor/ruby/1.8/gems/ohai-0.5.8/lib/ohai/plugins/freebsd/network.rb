#
# Author:: Bryan McLellan (btm@loftninjas.org)
# Copyright:: Copyright (c) 2009 Bryan McLellan
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

provides "network", "counters/network"

network[:default_interface] = from("route -n get default \| grep interface: \| awk \'/: / \{print \$2\}\'")

iface = Mash.new
popen4("/sbin/ifconfig -a") do |pid, stdin, stdout, stderr|
  stdin.close
  cint = nil
  stdout.each do |line|
    if line =~ /^([0-9a-zA-Z\.]+):\s+/
      cint = $1
      iface[cint] = Mash.new
      if cint =~ /^(\w+)(\d+.*)/
        iface[cint][:type] = $1
        iface[cint][:number] = $2
      end
    end
    # call the family lladdr to match linux for consistency
    if line =~ /\s+ether (.+?)\s/
      iface[cint][:addresses] = Mash.new unless iface[cint][:addresses]
      iface[cint][:addresses][$1] = { "family" => "lladdr" }
    end
    if line =~ /\s+inet ([\d.]+) netmask ([\da-fx]+)\s*\w*\s*([\d.]*)/
      iface[cint][:addresses] = Mash.new unless iface[cint][:addresses]
      # convert the netmask to decimal for consistency
      netmask = "#{$2[2,2].hex}.#{$2[4,2].hex}.#{$2[6,2].hex}.#{$2[8,2].hex}"
      if $3.empty?
        iface[cint][:addresses][$1] = { "family" => "inet", "netmask" => netmask }
      else
        # found a broadcast address
        iface[cint][:addresses][$1] = { "family" => "inet", "netmask" => netmask, "broadcast" => $3 }
      end
    end
    if line =~ /\s+inet6 ([a-f0-9\:]+)%?(\w*)\s+prefixlen\s+(\d+)\s*\w*\s*([\da-fx]*)/
      iface[cint][:addresses] = Mash.new unless iface[cint][:addresses]
      if $4.empty?
        iface[cint][:addresses][$1] = { "family" => "inet6", "prefixlen" => $3 }
      else
        # found a zone_id / scope
        iface[cint][:addresses][$1] = { "family" => "inet6", "zoneid" => $2, "prefixlen" => $3, "scopeid" => $4 }
      end
    end
    if line =~ /flags=\d+<(.+)>/
      flags = $1.split(',')
      iface[cint][:flags] = flags if flags.length > 0
    end
    if line =~ /metric: (\d+) mtu: (\d+)/
      iface[cint][:metric] = $1
      iface[cint][:mtu] = $2
    end
  end
end

popen4("arp -an") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    if line =~ /\((\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\) at ([a-fA-F0-9\:]+) on ([0-9a-zA-Z\.\:\-]+)/
      next unless iface[$3] # this should never happen
      iface[$3][:arp] = Mash.new unless iface[$3][:arp]
      iface[$3][:arp][$1] = $2.downcase
    end
  end
end

network["interfaces"] = iface

net_counters = Mash.new
# From netstat(1), not sure of the implications:
# Show the state of all network interfaces or a single interface
# which have been auto-configured (interfaces statically configured
# into a system, but not located at boot time are not shown). 
popen4("netstat -ibdn") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    # Name    Mtu Network       Address              Ipkts Ierrs     Ibytes    Opkts Oerrs     Obytes  Coll Drop
    # ed0    1500 <Link#1>      54:52:00:68:92:85   333604    26  151905886   175472     0   24897542     0  905 
    # $1                        $2                      $3    $4         $5       $6    $7         $8    $9  $10
    if line =~ /^([\w\.\*]+)\s+\d+\s+<Link#\d+>\s+([\w:]*)\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
      net_counters[$1] = Mash.new unless net_counters[$1]
      net_counters[$1]["rx"] = Mash.new unless net_counters[$1]["rx"]
      net_counters[$1]["tx"] = Mash.new unless net_counters[$1]["tx"]
      net_counters[$1]["rx"]["packets"] = $3
      net_counters[$1]["rx"]["errors"] = $4
      net_counters[$1]["rx"]["bytes"] = $5
      net_counters[$1]["tx"]["packets"] = $6
      net_counters[$1]["tx"]["errors"] = $7
      net_counters[$1]["tx"]["bytes"] = $8
      net_counters[$1]["tx"]["collisions"] = $9
      net_counters[$1]["tx"]["dropped"] = $10
    end
  end
end

counters[:network][:interfaces] = net_counters