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

provides "filesystem"

require "sigar"

fs = Mash.new

sigar = Sigar.new

sigar.file_system_list.each do |fsys|
  filesystem = fsys.dev_name
  fs[filesystem] = Mash.new
  fs[filesystem][:mount] = fsys.dir_name
  fs[filesystem][:fs_type] = fsys.sys_type_name
  fs[filesystem][:mount_options] = fsys.options
  begin
    usage = sigar.file_system_usage(fsys.dir_name)
    fs[filesystem][:kb_size] = (usage.total / 1024).to_s
    fs[filesystem][:kb_used] = ((usage.total - usage.free) / 1024).to_s
    fs[filesystem][:kb_available] = (usage.free / 1024).to_s
    fs[filesystem][:percent_used] = (usage.use_percent * 100).to_s + '%'
  rescue Exception => e
    #e.g. floppy or cdrom drive
  end
end

# Set the filesystem data
filesystem fs
