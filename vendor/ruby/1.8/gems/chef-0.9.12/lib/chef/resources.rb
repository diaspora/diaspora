#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

require 'chef/resource/apt_package'
require 'chef/resource/bash'
require 'chef/resource/breakpoint'
require 'chef/resource/cookbook_file'
require 'chef/resource/cron'
require 'chef/resource/csh'
require 'chef/resource/deploy'
require 'chef/resource/deploy_revision'
require 'chef/resource/directory'
require 'chef/resource/dpkg_package'
require 'chef/resource/easy_install_package'
require 'chef/resource/env'
require 'chef/resource/erl_call'
require 'chef/resource/execute'
require 'chef/resource/file'
require 'chef/resource/freebsd_package'
require 'chef/resource/gem_package'
require 'chef/resource/git'
require 'chef/resource/group'
require 'chef/resource/http_request'
require 'chef/resource/ifconfig'
require 'chef/resource/link'
require 'chef/resource/log'
require 'chef/resource/macports_package'
require 'chef/resource/mdadm'
require 'chef/resource/mount'
require 'chef/resource/ohai'
require 'chef/resource/package'
require 'chef/resource/pacman_package'
require 'chef/resource/perl'
require 'chef/resource/portage_package'
require 'chef/resource/python'
require 'chef/resource/remote_directory'
require 'chef/resource/remote_file'
require 'chef/resource/rpm_package'
require 'chef/resource/route'
require 'chef/resource/ruby'
require 'chef/resource/ruby_block'
require 'chef/resource/scm'
require 'chef/resource/script'
require 'chef/resource/service'
require 'chef/resource/subversion'
require 'chef/resource/template'
require 'chef/resource/timestamped_deploy'
require 'chef/resource/user'
require 'chef/resource/yum_package'
