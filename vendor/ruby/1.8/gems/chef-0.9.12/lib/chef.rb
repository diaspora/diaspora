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

require 'chef/version'

require 'extlib'
require 'chef/exceptions'
require 'chef/log'
require 'chef/config'
require 'chef/providers'
require 'chef/resources'
require 'chef/shell_out'

require 'chef/daemon'
require 'chef/webui_user'
require 'chef/openid_registration'

require 'chef/run_status'
require 'chef/handler'
require 'chef/handler/json_file'

require 'chef/monkey_patches/tempfile'
require 'chef/monkey_patches/dir'
require 'chef/monkey_patches/string'
