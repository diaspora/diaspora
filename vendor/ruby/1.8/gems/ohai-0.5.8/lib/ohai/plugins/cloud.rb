#
# Author:: Cary Penniman (<cary@rightscale.com>)
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

provides "cloud"

require_plugin "ec2"
require_plugin "rackspace"

# Make top-level cloud hashes
#
def create_objects
  cloud Mash.new
  cloud[:public_ips] = Array.new
  cloud[:private_ips] = Array.new
end

# ----------------------------------------
# ec2
# ----------------------------------------

# Is current cloud ec2?
#
# === Return
# true:: If ec2 Hash is defined
# false:: Otherwise
def on_ec2?
  ec2 != nil
end

# Fill cloud hash with ec2 values
def get_ec2_values 
  cloud[:public_ips] << ec2['public_ipv4']
  cloud[:private_ips] << ec2['local_ipv4']
  cloud[:provider] = "ec2"
end

# setup ec2 cloud  
if on_ec2?
  create_objects
  get_ec2_values
end

# ----------------------------------------
# rackspace
# ----------------------------------------

# Is current cloud rackspace?
#
# === Return
# true:: If rackspace Hash is defined
# false:: Otherwise
def on_rackspace?
  rackspace != nil
end

# Fill cloud hash with rackspace values
def get_rackspace_values 
  cloud[:public_ips] << rackspace['public_ip']
  cloud[:private_ips] << rackspace['private_ip']
  cloud[:provider] = "rackspace"
end

# setup rackspace cloud 
if on_rackspace?
  create_objects
  get_rackspace_values
end
