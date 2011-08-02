#
# Author:: Benjamin Black (<nostromo@gmail.com>)
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

provides "platform", "platform_version", "platform_build"

popen4("uname -X") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    case line
    when /^System =\s+(.+)$/
      platform = ($1.eql?("SunOS") ? "solaris2" : $1.downcase)
    when /^Release =\s+(.+)$/
      platform_version $1
    when /^KernelID =\s+(.+)$/
      platform_build $1
    end
  end
end
