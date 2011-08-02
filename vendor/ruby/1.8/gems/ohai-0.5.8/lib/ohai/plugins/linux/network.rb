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

provides "network", "counters/network"

network[:default_interface] = from("route -n \| grep -m 1 ^0.0.0.0 \| awk \'{print \$8\}\'")

def encaps_lookup(encap)
  return "Loopback" if encap.eql?("Local Loopback")
  return "PPP" if encap.eql?("Point-to-Point Protocol")
  return "SLIP" if encap.eql?("Serial Line IP")
  return "VJSLIP" if encap.eql?("VJ Serial Line IP")
  return "IPIP" if encap.eql?("IPIP Tunnel")
  return "6to4" if encap.eql?("IPv6-in-IPv4")
  encap
end

iface = Mash.new
net_counters = Mash.new
popen4("ifconfig -a") do |pid, stdin, stdout, stderr|
  stdin.close
  cint = nil
  stdout.each do |line|
    tmp_addr = nil
    if line =~ /^([0-9a-zA-Z\.\:\-_]+)\s+/
      cint = $1
      iface[cint] = Mash.new
      if cint =~ /^(\w+)(\d+.*)/
        iface[cint][:type] = $1
        iface[cint][:number] = $2
      end
    end
    if line =~ /Link encap:(Local Loopback)/ || line =~ /Link encap:(.+?)\s/
      iface[cint][:encapsulation] = encaps_lookup($1)
    end
    if line =~ /HWaddr (.+?)\s/
      iface[cint][:addresses] = Mash.new unless iface[cint][:addresses]
      iface[cint][:addresses][$1] = { "family" => "lladdr" }
    end
    if line =~ /inet addr:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
      iface[cint][:addresses] = Mash.new unless iface[cint][:addresses]
      iface[cint][:addresses][$1] = { "family" => "inet" }
      tmp_addr = $1
    end
    if line =~ /inet6 addr: ([a-f0-9\:]+)\/(\d+) Scope:(\w+)/
      iface[cint][:addresses] = Mash.new unless iface[cint][:addresses]
      iface[cint][:addresses][$1] = { "family" => "inet6", "prefixlen" => $2, "scope" => ($3.eql?("Host") ? "Node" : $3) }
    end
    if line =~ /Bcast:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
      iface[cint][:addresses][tmp_addr]["broadcast"] = $1
    end
    if line =~ /Mask:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
      iface[cint][:addresses][tmp_addr]["netmask"] = $1
    end
    flags = line.scan(/(UP|BROADCAST|DEBUG|LOOPBACK|POINTTOPOINT|NOTRAILERS|RUNNING|NOARP|PROMISC|ALLMULTI|SLAVE|MASTER|MULTICAST|DYNAMIC)\s/)
    if flags.length > 1
      iface[cint][:flags] = flags.flatten
    end
    if line =~ /MTU:(\d+)/
      iface[cint][:mtu] = $1
    end
    if line =~ /RX packets:(\d+) errors:(\d+) dropped:(\d+) overruns:(\d+) frame:(\d+)/
      net_counters[cint] = Mash.new unless net_counters[cint]
      net_counters[cint][:rx] = { "packets" => $1, "errors" => $2, "drop" => $3, "overrun" => $4, "frame" => $5 }
    end
    if line =~ /TX packets:(\d+) errors:(\d+) dropped:(\d+) overruns:(\d+) carrier:(\d+)/
      net_counters[cint][:tx] = { "packets" => $1, "errors" => $2, "drop" => $3, "overrun" => $4, "carrier" => $5 }
    end
    if line =~ /collisions:(\d+)/
      net_counters[cint][:tx]["collisions"] = $1
    end
    if line =~ /txqueuelen:(\d+)/
      net_counters[cint][:tx]["queuelen"] = $1
    end
    if line =~ /RX bytes:(\d+) \((\d+?\.\d+ .+?)\)/
      net_counters[cint][:rx]["bytes"] = $1
    end
    if line =~ /TX bytes:(\d+) \((\d+?\.\d+ .+?)\)/
      net_counters[cint][:tx]["bytes"] = $1
    end
  end
end

popen4("arp -an") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    if line =~ /^\S+ \((\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\) at ([a-fA-F0-9\:]+) \[(\w+)\] on ([0-9a-zA-Z\.\:\-]+)/
      next unless iface[$4] # this should never happen
      iface[$4][:arp] = Mash.new unless iface[$4][:arp]
      iface[$4][:arp][$1] = $2.downcase
    end
  end
end

counters[:network][:interfaces] = net_counters

network["interfaces"] = iface
