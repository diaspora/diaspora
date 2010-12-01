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

provides "filesystem"

fs = Mash.new

# Grab filesystem data from df
popen4("df") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    case line
    when /^Filesystem/
      next
    when /^(.+?)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+\%)\s+(.+)$/
      filesystem = $1
      fs[filesystem] = Mash.new
      fs[filesystem][:kb_size] = $2
      fs[filesystem][:kb_used] = $3
      fs[filesystem][:kb_available] = $4
      fs[filesystem][:percent_used] = $5
      fs[filesystem][:mount] = $6
    end
  end
end

# Grab mount information from mount
popen4("mount -l") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    if line =~ /^(.+?) on (.+?) \((.+?), (.+?)\)$/
      filesystem = $1
      fs[filesystem] = Mash.new unless fs.has_key?(filesystem)
      fs[filesystem][:mount] = $2
      fs[filesystem][:fs_type] = $3
      fs[filesystem][:mount_options] = $4.split(/,\s*/)
    end
  end
end

# Set the filesystem data
filesystem fs
