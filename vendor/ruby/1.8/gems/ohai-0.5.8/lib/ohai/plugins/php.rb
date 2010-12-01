#
# Author:: Doug MacEachern <dougm@vmware.com>
# Copyright:: Copyright (c) 2009 VMware, Inc.
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

provides "languages/php"

require_plugin "languages"

output = nil

php = Mash.new

status, stdout, stderr = run_command(:no_status_check => true, :command => "php -v")
if status == 0
  output = stdout.split
  if output.length >= 6
    php[:version] = output[1]
    php[:builddate] = "%s %s %s" % [output[4],output[5],output[6]]
  end
  languages[:php] = php if php[:version]
end

