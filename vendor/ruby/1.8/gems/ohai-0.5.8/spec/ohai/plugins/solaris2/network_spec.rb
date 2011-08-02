# 
#  Author:: Daniel DeLeo <dan@opscode.com>
#  Copyright:: Copyright (c) 2010 Opscode, Inc.
#  License:: Apache License, Version 2.0
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# 

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')

describe Ohai::System, "Solaris2.X network plugin" do
  
  before do
    solaris_ifconfig = <<-ENDIFCONFIG
lo0:3: flags=2001000849<UP,LOOPBACK,RUNNING,MULTICAST,IPv4,VIRTUAL> mtu 8232 index 1
        inet 127.0.0.1 netmask ff000000
e1000g0:3: flags=201000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4,CoS> mtu 1500 index 3
        inet 72.2.115.28 netmask ffffff80 broadcast 72.2.115.127
e1000g2:1: flags=201000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4,CoS> mtu 1500 index 4
        inet 10.2.115.28 netmask ffffff80 broadcast 10.2.115.127
        inet6 2001:0db8:3c4d:55:a00:20ff:fe8e:f3ad/64
ip.tun0: flags=2200851<UP,POINTOPOINT,RUNNING,MULTICAST,NONUD,IPv6> mtu 1480 index 3
       inet tunnel src 109.146.85.57   tunnel dst 109.146.85.212
       tunnel security settings  -->  use 'ipsecconf -ln -i ip.tun1'
       tunnel hop limit 60
       inet6 fe80::6d92:5539/10 --> fe80::6d92:55d4
ip.tun0:1: flags=2200851<UP,POINTOPOINT,RUNNING,MULTICAST,NONUD,IPv6> mtu 1480 index 3
       inet6 2::45/128 --> 2::46
lo0: flags=1000849<UP,LOOPBACK,RUNNING,MULTICAST,IPv4> mtu 8232 index 1
    inet 127.0.0.1 netmask ff000000
eri0: flags=1004843<UP,BROADCAST,RUNNING,MULTICAST,DHCP,IPv4> mtu 1500 \
index 2
    inet 172.17.128.208 netmask ffffff00 broadcast 172.17.128.255
ip6.tun0: flags=10008d1<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST,IPv4> \
mtu 1460
    index 3
    inet6 tunnel src fe80::1 tunnel dst fe80::2
    tunnel security settings  -->  use 'ipsecconf -ln -i ip.tun1'
    tunnel hop limit 60 tunnel encapsulation limit 4
    inet 10.0.0.208 --> 10.0.0.210 netmask ff000000
qfe1: flags=2000841<UP,RUNNING,MULTICAST,IPv6> mtu 1500 index 3
 usesrc vni0
 inet6 fe80::203:baff:fe17:4be0/10
 ether 0:3:ba:17:4b:e0
vni0: flags=2002210041<UP,RUNNING,NOXMIT,NONUD,IPv6,VIRTUAL> mtu 0
 index 5
 srcof qfe1
 inet6 fe80::203:baff:fe17:4444/128
ENDIFCONFIG

    solaris_netstat_rn = <<-NETSTAT_RN
Routing Table: IPv4
  Destination           Gateway           Flags  Ref     Use     Interface 
-------------------- -------------------- ----- ----- ---------- --------- 
default              10.13.37.1           UG        1          0 e1000g0   
10.13.37.0           10.13.37.157         U         1          2 e1000g0   
127.0.0.1            127.0.0.1            UH        1         35 lo0       
 
Routing Table: IPv6
  Destination/Mask            Gateway                   Flags Ref   Use    If   
--------------------------- --------------------------- ----- --- ------- ----- 
fe80::/10                   fe80::250:56ff:fe13:3757    U       1       0 e1000g0 
::1                         ::1                         UH      1       0 lo0   
NETSTAT_RN

    @solaris_route_get = <<-ROUTE_GET
   route to: default
destination: default
       mask: default
    gateway: 10.13.37.1
  interface: e1000g0
      flags: <UP,GATEWAY,DONE,STATIC>
 recvpipe  sendpipe  ssthresh    rtt,ms rttvar,ms  hopcount      mtu     expire
       0         0         0         0         0         0      1500         0 
ROUTE_GET

    @stdin = mock("STDIN", :null_object => true)
    @ifconfig_lines = solaris_ifconfig.split("\n")

    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:network] = Mash.new
 
    @ohai.stub(:popen4).with("ifconfig -a")
    @ohai.stub(:popen4).with("arp -an")
  end
  
  describe "gathering IP layer address info" do
    before do
      @ohai.stub!(:popen4).with("ifconfig -a").and_yield(nil, @stdin, @ifconfig_lines, nil)
      @ohai._require_plugin("solaris2::network")
    end

    it "completes the run" do
      @ohai['network'].should_not be_nil
    end

    it "detects the interfaces" do
      @ohai['network']['interfaces'].keys.sort.should == ["e1000g0:3", "e1000g2:1", "eri0", "ip.tun0", "ip.tun0:1", "lo0", "lo0:3", "qfe1"]
    end

    it "detects the ip addresses of the interfaces" do
      @ohai['network']['interfaces']['e1000g0:3']['addresses'].keys.should include('72.2.115.28')
    end

    it "detects the encapsulation type of the interfaces" do
      @ohai['network']['interfaces']['e1000g0:3']['encapsulation'].should == 'Ethernet'
    end
  end

  # TODO: specs for the arp -an stuff, check that it correctly adds the MAC addr to the right iface, etc.

  describe "setting the node's default IP address attribute" do
    before do
      @stdout = mock("Pipe, stdout, cmd=`route get default`", :read => @solaris_route_get)
      @ohai.stub!(:popen4).with("route get default").and_yield(nil,@stdin, @stdout, nil)
      @ohai._require_plugin("solaris2::network")
    end

    it "finds the default interface by asking which iface has the default route" do
      @ohai[:network][:default_interface].should == 'e1000g0'
    end
  end
end
 
