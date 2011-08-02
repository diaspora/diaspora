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

provides "system_profile"

begin  
  require 'plist'

  system_profile Array.new
  popen4("system_profiler -xml -detailLevel mini") do |pid, stdin, stdout, stderr|
    stdin.close
    Plist::parse_xml(stdout.read).each do |e|
      system_profile << e
    end
  end
rescue LoadError => e
  Ohai::Log.debug("Can't load gem: #{e})")
end