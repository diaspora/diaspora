#
# Author:: James Gartrell (<jgartrel@gmail.com>)
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

require 'ruby-wmi'

fs = Mash.new
ld_info = Mash.new

# Grab filesystem data from WMI
# Note: we should really be parsing Win32_Volume and Win32_Mapped drive
disks = WMI::Win32_LogicalDisk.find(:all)
disks.each do |disk|
    filesystem = disk.DeviceID
    fs[filesystem] = Mash.new
    ld_info[filesystem] = Mash.new
    disk.properties_.each do |p|
      ld_info[filesystem][p.name.wmi_underscore.to_sym] = disk[p.name]
    end
    fs[filesystem][:kb_size] = ld_info[filesystem][:size].to_i / 1000
    fs[filesystem][:kb_available] = ld_info[filesystem][:free_space].to_i / 1000
    fs[filesystem][:kb_used] = fs[filesystem][:kb_size].to_i - fs[filesystem][:kb_available].to_i
    fs[filesystem][:percent_used]  = (fs[filesystem][:kb_size].to_i != 0 ? fs[filesystem][:kb_used].to_i * 100 / fs[filesystem][:kb_size].to_i : 0)
    fs[filesystem][:mount] = ld_info[filesystem][:name]
    fs[filesystem][:fs_type] = ld_info[filesystem][:file_system].downcase unless ld_info[filesystem][:file_system] == nil
    fs[filesystem][:volume_name] = ld_info[filesystem][:volume_name]
end

# Set the filesystem data
filesystem fs
