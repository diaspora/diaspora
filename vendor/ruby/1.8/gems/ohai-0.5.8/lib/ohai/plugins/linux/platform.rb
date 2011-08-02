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
def get_redhatish_platform(contents)
  contents[/^Red Hat/i] ? "redhat" : contents[/(\w+)/i, 1].downcase
end

def get_redhatish_version(contents)
  contents[/Rawhide/i] ? contents[/((\d+) \(Rawhide\))/i, 1].downcase : contents[/release ([\d\.]+)/, 1]
end

provides "platform", "platform_version"

require_plugin 'linux::lsb'

if lsb[:id]
  platform lsb[:id].downcase
  platform_version lsb[:release]
elsif File.exists?("/etc/debian_version")
  platform "debian"
  platform_version File.read("/etc/debian_version").chomp
elsif File.exists?("/etc/redhat-release")
  contents = File.read("/etc/redhat-release").chomp
  platform get_redhatish_platform(contents)
  platform_version get_redhatish_version(contents)
elsif File.exists?("/etc/system-release")
  contents = File.read("/etc/system-release").chomp
  platform get_redhatish_platform(contents)
  platform_version get_redhatish_version(contents)
elsif File.exists?('/etc/gentoo-release')
  platform "gentoo"
  platform_version IO.read('/etc/gentoo-release').scan(/(\d+|\.+)/).join
elsif File.exists?('/etc/SuSE-release')
  platform "suse"
  platform_version File.read("/etc/SuSE-release").scan(/VERSION = (\d+)\nPATCHLEVEL = (\d+)/).flatten.join(".")
elsif File.exists?('/etc/arch-release')
  platform "arch"
  # no way to determine platform_version in a rolling release distribution
  # kernel release will be used - ex. 2.6.32-ARCH
end
