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

provides "keys/ssh"

require_plugin "keys"

keys[:ssh] = Mash.new

keys[:ssh][:host_dsa_public] = IO.read("/opt/ssh/etc/ssh_host_dsa_key.pub").split[1]
keys[:ssh][:host_rsa_public] = IO.read("/opt/ssh/etc/ssh_host_rsa_key.pub").split[1]
