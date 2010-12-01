#
# Author:: Thom May (<thom@clearairturbulence.org>)
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

provides "languages/python"

require_plugin "languages"

output = nil

python = Mash.new

status, stdout, stderr = run_command(:no_status_check => true, :command => "python -c \"import sys; print sys.version\"")

if status == 0
  output = stdout.split
  python[:version] = output[0]
  if output.length >= 6
    python[:builddate] = "%s %s %s %s" % [output[2],output[3],output[4],output[5].gsub!(/\)/,'')]
  end

  languages[:python] = python if python[:version] and python[:builddate]
end
