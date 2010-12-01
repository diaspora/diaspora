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

#wrapper around a subset of the NetUser* APIs.
#nothing Chef specific, but not complete enough to be its own gem, so util for now.
class Chef::Util::Windows::NetUser < Chef::Util::Windows

  private

  LogonUser = Windows::API.new('LogonUser', 'SSSLLP', 'I', 'advapi32')

  DOMAIN_GROUP_RID_USERS = 0x00000201

  UF_SCRIPT              = 0x000001
  UF_ACCOUNTDISABLE      = 0x000002
  UF_PASSWD_CANT_CHANGE  = 0x000040
  UF_NORMAL_ACCOUNT      = 0x000200
  UF_DONT_EXPIRE_PASSWD  = 0x010000

  #[:symbol_name, default_val]
  #default_val duals as field type
  #array index duals as structure offset
  USER_INFO_3 = [
    [:name, nil],
    [:password, nil],
    [:password_age, 0],
    [:priv, 0], #"The NetUserAdd and NetUserSetInfo functions ignore this member"
    [:home_dir, nil],
    [:comment, nil],
    [:flags, UF_SCRIPT|UF_DONT_EXPIRE_PASSWD|UF_NORMAL_ACCOUNT],
    [:script_path, nil],
    [:auth_flags, 0],
    [:full_name, nil],
    [:user_comment, nil],
    [:parms, nil],
    [:workstations, nil],
    [:last_logon, 0],
    [:last_logoff, 0],
    [:acct_expires, -1],
    [:max_storage, -1],
    [:units_per_week, 0],
    [:logon_hours, nil],
    [:bad_pw_count, 0],
    [:num_logons, 0],
    [:logon_server, nil],
    [:country_code, 0],
    [:code_page, 0],
    [:user_id, 0],
    [:primary_group_id, DOMAIN_GROUP_RID_USERS],
    [:profile, nil],
    [:home_dir_drive, nil],
    [:password_expired, 0]
  ]

  USER_INFO_3_TEMPLATE =
    USER_INFO_3.collect { |field| field[1].class == Fixnum ? 'i' : 'L' }.join

  SIZEOF_USER_INFO_3 = #sizeof(USER_INFO_3)
    USER_INFO_3.inject(0){|sum,item|
      sum + (item[1].class == Fixnum ? 4 : PTR_SIZE)
    }

  def user_info_3(args)
    USER_INFO_3.collect { |field|
      args.include?(field[0]) ? args[field[0]] : field[1]
    }
  end

  def user_info_3_pack(user)
    user.collect { |v|
      v.class == Fixnum ? v : str_to_ptr(multi_to_wide(v))
    }.pack(USER_INFO_3_TEMPLATE)
  end

  def user_info_3_unpack(buffer)
    user = Hash.new
    USER_INFO_3.each_with_index do |field,offset|
      user[field[0]] = field[1].class == Fixnum ?
        dword_to_i(buffer, offset) : lpwstr_to_s(buffer, offset)
    end
    user
  end

  def set_info(args)
    user = user_info_3(args)
    buffer = user_info_3_pack(user)
    rc = NetUserSetInfo.call(nil, @name, 3, buffer, nil)
    if rc != NERR_Success
      raise ArgumentError, get_last_error(rc)
    end
  end

  public

  def initialize(username)
    @username = username
    @name = multi_to_wide(username)
  end

  LOGON32_PROVIDER_DEFAULT = 0
  LOGON32_LOGON_NETWORK = 3
  #XXX for an extra painful alternative, see: http://support.microsoft.com/kb/180548
  def validate_credentials(passwd)
    token = 0.chr * PTR_SIZE
    res = LogonUser.call(@username, nil, passwd,
                         LOGON32_LOGON_NETWORK, LOGON32_PROVIDER_DEFAULT, token)
    if res == 0
      return false
    end
    ::Windows::Handle::CloseHandle.call(token.unpack('L')[0])
    return true
  end

  def get_info
    ptr  = 0.chr * PTR_SIZE
    rc = NetUserGetInfo.call(nil, @name, 3, ptr)

    if rc != NERR_Success
      raise ArgumentError, get_last_error(rc)
    end

    ptr = ptr.unpack('L')[0]
    buffer = 0.chr * SIZEOF_USER_INFO_3
    memcpy(buffer, ptr, buffer.size)
    NetApiBufferFree(ptr)
    user_info_3_unpack(buffer)
  end

  def add(args)
    user = user_info_3(args)
    buffer = user_info_3_pack(user)

    rc = NetUserAdd.call(nil, 3, buffer, rc)
    if rc != NERR_Success
      raise ArgumentError, get_last_error(rc)
    end

    #usri3_primary_group_id:
    #"When you call the NetUserAdd function, this member must be DOMAIN_GROUP_RID_USERS"
    NetLocalGroupAddMembers(nil, multi_to_wide("Users"), 3, buffer[0,PTR_SIZE], 1)
  end

  def user_modify(&proc)
    user = get_info
    user[:last_logon] = user[:units_per_week] = 0 #ignored as per USER_INFO_3 doc
    user[:logon_hours] = nil #PBYTE field; \0 == no changes
    proc.call(user)
    set_info(user)
  end

  def update(args)
    user_modify do |user|
      args.each do |key,val|
        user[key] = val
      end
    end
  end

  def delete
    rc = NetUserDel.call(nil, @name)
    if rc != NERR_Success
      raise ArgumentError, get_last_error(rc)
    end
  end

  def disable_account
    user_modify do |user|
      user[:flags] |= UF_ACCOUNTDISABLE
    end
  end

  def enable_account
    user_modify do |user|
      user[:flags] &= ~UF_ACCOUNTDISABLE
    end
  end

  def check_enabled
    (get_info()[:flags] & UF_ACCOUNTDISABLE) != 0
  end
end
