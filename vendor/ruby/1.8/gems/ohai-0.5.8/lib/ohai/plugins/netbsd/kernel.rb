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

provides "kernel"

kernel[:os] = kernel[:name]
kernel[:securelevel] = from_with_regex("sysctl kern.securelevel", /kern.securelevel=(.+)$/)

mod = Mash.new
popen4("/usr/bin/modstat") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    #  1    7 0xc0400000 97f830   kernel
    if line =~ /(\d+)\s+(\d+)\s+([0-9a-fx]+)\s+([0-9a-fx]+)\s+([a-zA-Z0-9\_]+)/
      kld[$5] = { :size => $4, :refcount => $2 }
    end
  end
end

kernel[:modules] = mod unless mod.empty?
