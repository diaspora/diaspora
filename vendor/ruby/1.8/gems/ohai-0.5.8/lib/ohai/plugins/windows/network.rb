#
# Author:: James Gartrell (<jgartrel@gmail.com>)
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

require 'ruby-wmi'

def encaps_lookup(encap)
  return "Ethernet" if encap.eql?("Ethernet 802.3")
  encap
end

def derive_bcast(ipaddr, ipmask, zero_bcast = false)
  begin
    ipaddr_int = ipaddr.split(".").collect{ |x| x.to_i}.pack("C4").unpack("N").first
    ipmask_int = ipmask.split(".").collect{ |x| x.to_i}.pack("C4").unpack("N").first
    if zero_bcast
      bcast_int = ipaddr_int & ipmask_int
    else
      bcast_int = ipaddr_int | 2 ** 32 - ipmask_int - 1  
    end  
    bcast = [bcast_int].pack("N").unpack("C4").join(".")                                     
    return bcast
  rescue
    return nil
  end
end

iface = Mash.new
iface_config = Mash.new
iface_instance = Mash.new

adapters = WMI::Win32_NetworkAdapterConfiguration.find(:all)
adapters.each do |adapter|
    i = adapter.Index
    iface_config[i] = Mash.new
    adapter.properties_.each do |p|
      iface_config[i][p.name.wmi_underscore.to_sym] = adapter[p.name]
    end
end

adapters = WMI::Win32_NetworkAdapter.find(:all)
adapters.each do |adapter|
    i = adapter.Index
    iface_instance[i] = Mash.new
     adapter.properties_.each do |p|
      iface_instance[i][p.name.wmi_underscore.to_sym] = adapter[p.name]
    end
end

iface_instance.keys.each do |i|
  if iface_config[i][:ip_enabled] and iface_instance[i][:net_connection_id] and iface_instance[i][:interface_index]
    cint = sprintf("0x%X", iface_instance[i][:interface_index])
    iface[cint] = Mash.new
    iface[cint][:configuration] = iface_config[i]
    iface[cint][:instance] = iface_instance[i]

    iface[cint][:counters] = Mash.new
    iface[cint][:addresses] = Mash.new
    iface[cint][:configuration][:ip_address].each_index do |i|
      begin
         if iface[cint][:configuration][:ip_address][i] =~ /./
           iface[cint][:addresses][iface[cint][:configuration][:ip_address][i]] = {
             "family"    => "inet",
             "netmask"   => iface[cint][:configuration][:ip_subnet][i],
             "broadcast" => derive_bcast( iface[cint][:configuration][:ip_address][i],
                                          iface[cint][:configuration][:ip_subnet][i],
                                          iface[cint][:configuration][:ip_use_zero_broadcast]
             )
           }
         end
      rescue
      end
    end
    iface[cint][:configuration][:mac_address].each do |mac_addr|
      iface[cint][:addresses][mac_addr] = {
        "family"    => "lladdr"
      }
    end
    iface[cint][:mtu] = iface[cint][:configuration][:mtu]
    iface[cint][:type] = iface[cint][:instance][:adapter_type]
    iface[cint][:arp] = {}
    iface[cint][:encapsulation] = encaps_lookup(iface[cint][:instance][:adapter_type])
  end
end

cint=nil
from("arp /a").split("\n").each do |line|
  if line == ""
    cint = nil
  end
  if line =~ /^Interface:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+[-]+\s+(0x\d+)/
    cint = $2
  end
  next unless iface[cint]
  if line =~ /^\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([a-fA-F0-9\:-]+)/
    iface[cint][:arp][$1] = $2.gsub("-",":").downcase
  end
end

network["interfaces"] = iface
