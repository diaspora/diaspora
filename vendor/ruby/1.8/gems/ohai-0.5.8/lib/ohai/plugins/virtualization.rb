#
# Author:: Benjamin Black (<bb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

provides "virtualization"

require_plugin "#{os}::virtualization"

unless virtualization.nil? || !(virtualization[:role].eql?("host"))
  begin
    require 'libvirt'
    require 'hpricot'

    emu = (virtualization[:emulator].eql?('kvm') ? 'qemu' : virtualization[:emulator])
    virtualization[:libvirt_version] = Libvirt::version(emu)[0].to_s

    virtconn = Libvirt::open_read_only("#{emu}:///system")

    virtualization[:uri] = virtconn.uri
    virtualization[:capabilities] = Mash.new
    virtualization[:capabilities][:xml_desc] = (virtconn.capabilities.split("\n").collect {|line| line.strip}).join
    #xdoc = Hpricot virtualization[:capabilities][:xml_desc]
  
    virtualization[:nodeinfo] = Mash.new
    ni = virtconn.node_get_info
    ['cores','cpus','memory','mhz','model','nodes','sockets','threads'].each {|a| virtualization[:nodeinfo][a] = ni.send(a)}

    virtualization[:domains] = Mash.new
    virtconn.list_domains.each do |d|
      dv = virtconn.lookup_domain_by_id d
      virtualization[:domains][dv.name] = Mash.new
      virtualization[:domains][dv.name][:id] = d
      virtualization[:domains][dv.name][:xml_desc] = (dv.xml_desc.split("\n").collect {|line| line.strip}).join
      ['os_type','uuid'].each {|a| virtualization[:domains][dv.name][a] = dv.send(a)}
      ['cpu_time','max_mem','memory','nr_virt_cpu','state'].each {|a| virtualization[:domains][dv.name][a] = dv.info.send(a)}
      #xdoc = Hpricot virtualization[:domains][dv.name][:xml_desc]
    
    end

    virtualization[:networks] = Mash.new
    virtconn.list_networks.each do |n|
      nv = virtconn.lookup_network_by_name n
      virtualization[:networks][n] = Mash.new
      virtualization[:networks][n][:xml_desc] = (nv.xml_desc.split("\n").collect {|line| line.strip}).join
      ['bridge_name','uuid'].each {|a| virtualization[:networks][n][a] = nv.send(a)}
      #xdoc = Hpricot virtualization[:networks][n][:xml_desc]
    
    end

    virtualization[:storage] = Mash.new
    virtconn.list_storage_pools.each do |pool|
      sp = virtconn.lookup_storage_pool_by_name pool
      virtualization[:storage][pool] = Mash.new
      virtualization[:storage][pool][:xml_desc] = (sp.xml_desc.split("\n").collect {|line| line.strip}).join
      ['autostart','uuid'].each {|a| virtualization[:storage][pool][a] = sp.send(a)}
      ['allocation','available','capacity','state'].each {|a| virtualization[:storage][pool][a] = sp.info.send(a)}
      #xdoc = Hpricot virtualization[:storage][pool][:xml_desc]

      virtualization[:storage][pool][:volumes] = Mash.new
      sp.list_volumes.each do |v|
        virtualization[:storage][pool][:volumes][v] = Mash.new
        sv = sp.lookup_volume_by_name pool
        ['key','name','path'].each {|a| virtualization[:storage][pool][:volumes][v][a] = sv.send(a)}
        ['allocation','capacity','type'].each {|a| virtualization[:storage][pool][:volumes][v][a] = sv.info.send(a)}
      end
    end

    virtconn.close
  rescue LoadError => e
    Ohai::Log.debug("Can't load gem: #{e}.  virtualization plugin is disabled.")
  end
end
