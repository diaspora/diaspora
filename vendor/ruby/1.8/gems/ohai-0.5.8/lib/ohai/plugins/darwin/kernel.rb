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

provides "kernel"

kernel[:os] = kernel[:name]

if from("sysctl -n hw.optional.x86_64").to_i == 1
  kernel[:machine] = 'x86_64'
end

kext = Mash.new
popen4("kextstat -k -l") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    if line =~ /(\d+)\s+(\d+)\s+0x[0-9a-f]+\s+0x([0-9a-f]+)\s+0x[0-9a-f]+\s+([a-zA-Z0-9\.]+) \(([0-9\.]+)\)/
      kext[$4] = { :version => $5, :size => $3.hex, :index => $1, :refcount => $2 }
    end
  end
end

kernel[:modules] = kext
