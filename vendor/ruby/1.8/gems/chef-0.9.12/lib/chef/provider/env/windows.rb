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

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'ruby-wmi'
  require 'Win32API'
end

class Chef
  class Provider
    class Env
      class Windows < Chef::Provider::Env

        def create_env
          obj = env_obj(@new_resource.key_name)
          unless obj
            obj = WIN32OLE.connect("winmgmts://").get("Win32_Environment").spawninstance_
            obj.name = @new_resource.key_name
            obj.username = "<System>"
          end
          obj.variablevalue = @new_resource.value
          obj.put_
          broadcast_env_change
        end

        def delete_env
          obj = env_obj(@new_resource.key_name)
          if obj
            obj.delete_
            broadcast_env_change
          end
        end

        def env_value(key_name)
          obj = env_obj(key_name)
          return obj ? obj.variablevalue : nil
        end

        def env_obj(key_name)
          WMI::Win32_Environment.find(:first,
                                      :conditions => { :name => key_name })
        end

        #see: http://msdn.microsoft.com/en-us/library/ms682653%28VS.85%29.aspx
        HWND_BROADCAST = 0xffff
        WM_SETTINGCHANGE = 0x001A
        SMTO_BLOCK = 0x0001
        SMTO_ABORTIFHUNG = 0x0002
        SMTO_NOTIMEOUTIFNOTHUNG = 0x0008

        def broadcast_env_change
          result = 0
          flags = SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_NOTIMEOUTIFNOTHUNG
          @send_message ||= Win32API.new('user32', 'SendMessageTimeout', 'LLLPLLP', 'L')
          @send_message.call(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment', flags, 5000, result)
        end
      end
    end
  end
end
