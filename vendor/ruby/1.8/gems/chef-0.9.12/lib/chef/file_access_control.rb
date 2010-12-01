#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2008, 2010 Opscode, Inc.
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

require 'chef/log'

class Chef

  # == Chef::FileAccessControl
  # FileAccessControl objects set the owner, group and mode of +file+ to
  # the values specified by a value object, usually a Chef::Resource.
  class FileAccessControl
    UINT = (1 << 32)
    UID_MAX = (1 << 31)
  
    attr_reader :resource
  
    attr_reader :file
  
    # FileAccessControl objects set the owner, group and mode of +file+ to
    # the values specified by +resource+. +file+ is completely independent
    # of any file or path attribute on +resource+, so it is possible to set
    # access control settings on a tempfile (for example).
    # === Arguments:
    # resource:   probably a Chef::Resource::File object (or subclass), but
    #             this is not required. Must respond to +owner+, +group+,
    #             and +mode+
    # file:       The file whose access control settings you wish to modify,
    #             given as a String.
    def initialize(resource, file)
      @resource, @file = resource, file
      @modified = false
    end
  
    def modified?
      @modified
    end
  
    def set_all
      set_owner
      set_group
      set_mode
    end
  
    # Workaround the fact that Ruby's Etc module doesn't believe in negative
    # uids, so negative uids show up as the diminished radix complement of
    # a uint. For example, a uid of -2 is reported as 4294967294
    def dimished_radix_complement(int)
      if int > UID_MAX
        int - UINT
      else
        int
      end
    end
  
    def target_uid
      return nil if resource.owner.nil?
      if resource.owner.kind_of?(String)
        dimished_radix_complement( Etc.getpwnam(resource.owner).uid )
      elsif resource.owner.kind_of?(Integer)
        resource.owner
      else
        Chef::Log.error("The `owner` parameter of the #@resource resource is set to an invalid value (#{resource.owner.inspect})")
        raise ArgumentError, "cannot resolve #{resource.owner.inspect} to uid, owner must be a string or integer"
      end
    rescue ArgumentError
      raise Chef::Exceptions::UserIDNotFound, "cannot determine user id for '#{resource.owner}', does the user exist on this system?"
    end
  
    def set_owner
      if (uid = target_uid) && (uid != stat.uid)
        Chef::Log.debug("setting owner on #{file} to #{uid}")
        File.chown(uid, nil, file)
        modified
      end
    end
  
    def target_gid
      return nil if resource.group.nil?
      if resource.group.kind_of?(String)
        dimished_radix_complement( Etc.getgrnam(resource.group).gid )
      elsif resource.group.kind_of?(Integer)
        resource.group
      else
        Chef::Log.error("The `group` parameter of the #@resource resource is set to an invalid value (#{resource.owner.inspect})")
        raise ArgumentError, "cannot resolve #{resource.group.inspect} to gid, group must be a string or integer"
      end
    rescue ArgumentError
      raise Chef::Exceptions::GroupIDNotFound, "cannot determine group id for '#{resource.group}', does the group exist on this system?"
    end
  
    def set_group
      if (gid = target_gid) && (gid != stat.gid)
        Chef::Log.debug("setting group on #{file} to #{gid}")
        File.chown(nil, gid, file)
        modified
      end
    end

    def target_mode
      return nil if resource.mode.nil?
      (resource.mode.respond_to?(:oct) ? resource.mode.oct : resource.mode.to_i) & 007777
    end

    def set_mode
      if (mode = target_mode) && (mode != (stat.mode & 007777))
        Chef::Log.debug("setting mode on #{file} to #{mode.to_s(8)}")
        File.chmod(target_mode, file)
        modified
      end
    end
  

    def stat
      @stat ||= ::File.stat(file)
    end
  
    private
  
    def modified
      @modified = true
    end
  
  end
end
