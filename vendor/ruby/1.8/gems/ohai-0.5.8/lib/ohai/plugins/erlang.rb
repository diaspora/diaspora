#
# Author:: Joe Williams (<joe@joetify.com>)
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

provides "languages/erlang"

require_plugin "languages"

output = nil

erlang = Mash.new
status, stdout, stderr = run_command(:no_status_check => true, :command => "erl +V")

if status == 0
  output = stderr.split
  if output.length >= 6
    options = output[1]
    options.gsub!(/(\(|\))/, '')
    erlang[:version] = output[5]
    erlang[:options] = options.split(',')
    erlang[:emulator] = output[2].gsub!(/(\(|\))/, '')
    if erlang[:version] and erlang[:options] and erlang[:emulator]
      languages[:erlang] = erlang
    end
  end
end
