#
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Copyright:: Copyright (c) 2010 VMware, Inc.
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

#simple wrapper around Volume APIs. might be possible with WMI, but possibly more complex.

require 'chef/util/windows'
require 'windows/volume'

class Chef::Util::Windows::Volume < Chef::Util::Windows

  private
  include Windows::Volume
  #XXX not defined in the current windows-pr release
  DeleteVolumeMountPoint =
    Windows::API.new('DeleteVolumeMountPoint', 'S', 'B') unless defined? DeleteVolumeMountPoint

  public

  def initialize(name)
    name += "\\" unless name =~ /\\$/ #trailing slash required
    @name = name
  end
  
  def device
    buffer = 0.chr * 256
    if GetVolumeNameForVolumeMountPoint(@name, buffer, buffer.size)
      return buffer[0,buffer.size].unpack("Z*")[0]
    else
      raise ArgumentError, get_last_error
    end
  end

  def delete
    unless DeleteVolumeMountPoint.call(@name)
      raise ArgumentError, get_last_error
    end
  end

  def add(device)
    unless SetVolumeMountPoint(@name, device)
      raise ArgumentError, get_last_error
    end
  end
end
