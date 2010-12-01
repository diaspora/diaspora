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

require 'chef/util/windows'

#wrapper around a subset of the NetGroup* APIs.
#nothing Chef specific, but not complete enough to be its own gem, so util for now.
class Chef::Util::Windows::NetGroup < Chef::Util::Windows

  private

  def pack_str(s)
    [str_to_ptr(s)].pack('L')
  end

  def modify_members(members, func)
    buffer = 0.chr * (members.size * PTR_SIZE)
    members.each_with_index do |member,offset|
      buffer[offset*PTR_SIZE,PTR_SIZE] = pack_str(multi_to_wide(member))
    end
    rc = func.call(nil, @name, 3, buffer, members.size)
    if rc != NERR_Success
      raise ArgumentError, get_last_error(rc)
    end
  end

  public

  def initialize(groupname)
    @name = multi_to_wide(groupname)
  end

  def local_get_members
    group_members = []
    handle = 0.chr * PTR_SIZE
    rc = ERROR_MORE_DATA

    while rc == ERROR_MORE_DATA
      ptr   = 0.chr * PTR_SIZE
      nread = 0.chr * PTR_SIZE
      total = 0.chr * PTR_SIZE

      rc = NetLocalGroupGetMembers.call(nil, @name, 1, ptr, -1,
                                        nread, total, handle)
      if (rc == NERR_Success) || (rc == ERROR_MORE_DATA)
        ptr = ptr.unpack('L')[0]
        nread = nread.unpack('i')[0]
        members = 0.chr * (nread * (PTR_SIZE * 3)) #nread * sizeof(LOCALGROUP_MEMBERS_INFO_1)
        memcpy(members, ptr, members.size)

        #3 pointer fields in LOCALGROUP_MEMBERS_INFO_1, offset 2*PTR_SIZE is lgrmi1_name
        nread.times do |i|
          offset = (i * 3) + 2
          member = lpwstr_to_s(members, offset)
          group_members << member
        end
        NetApiBufferFree(ptr)
      else
        raise ArgumentError, get_last_error(rc)
      end
    end
    group_members
  end

  def local_add
    rc = NetLocalGroupAdd.call(nil, 0, pack_str(@name), nil)
    if rc != NERR_Success
      raise ArgumentError, get_last_error(rc)
    end
  end

  def local_set_members(members)
    modify_members(members, NetLocalGroupSetMembers)
  end

  def local_add_members(members)
    modify_members(members, NetLocalGroupAddMembers)
  end

  def local_delete
    rc = NetLocalGroupDel.call(nil, @name)
    if rc != NERR_Success
      raise ArgumentError, get_last_error(rc)
    end
  end
end
