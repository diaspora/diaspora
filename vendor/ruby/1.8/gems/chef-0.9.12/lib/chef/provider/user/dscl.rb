#
# Author:: Dreamcat4 (<dreamcat4@gmail.com>)
# Copyright:: Copyright (c) 2009 OpsCode, Inc.
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

require 'chef/mixin/shell_out'
require 'chef/provider/user'
require 'openssl'

class Chef
  class Provider
    class User
      class Dscl < Chef::Provider::User
        include Chef::Mixin::ShellOut
        
        NFS_HOME_DIRECTORY        = %r{^NFSHomeDirectory: (.*)$}
        AUTHENTICATION_AUTHORITY  = %r{^AuthenticationAuthority: (.*)$}
        
        def dscl(*args)
          shell_out("dscl . -#{args.join(' ')}")
        end

        def safe_dscl(*args)
          result = dscl(*args)
          return "" if ( args.first =~ /^delete/ ) && ( result.exitstatus != 0 )
          raise(Chef::Exceptions::DsclCommandFailed,"dscl error: #{result.inspect}") unless result.exitstatus == 0
          raise(Chef::Exceptions::DsclCommandFailed,"dscl error: #{result.inspect}") if result.stdout =~ /No such key: /
          return result.stdout
        end

        # This is handled in providers/group.rb by Etc.getgrnam()
        # def user_exists?(user)
        #   users = safe_dscl("list /Users")
        #   !! ( users =~ Regexp.new("\n#{user}\n") )
        # end

        # get a free UID greater than 200
        def get_free_uid(search_limit=1000)
          uid = nil; next_uid_guess = 200
          users_uids = safe_dscl("list /Users uid")
          while(next_uid_guess < search_limit + 200)
            if users_uids =~ Regexp.new("#{Regexp.escape(next_uid_guess.to_s)}\n")
              next_uid_guess += 1
            else
              uid = next_uid_guess
              break
            end
          end
          return uid || raise("uid not found. Exhausted. Searched #{search_limit} times")
        end

        def uid_used?(uid)
          return false unless uid
          users_uids = safe_dscl("list /Users uid")
          !! ( users_uids =~ Regexp.new("#{Regexp.escape(uid.to_s)}\n") )
        end

        def set_uid
          @new_resource.uid(get_free_uid) if (@new_resource.uid.nil? || @new_resource.uid == '')
          if uid_used?(@new_resource.uid)
            raise(Chef::Exceptions::RequestedUIDUnavailable, "uid #{@new_resource.uid} is already in use")
          end
          safe_dscl("create /Users/#{@new_resource.username} UniqueID #{@new_resource.uid}")
        end

        def modify_home
          return safe_dscl("delete /Users/#{@new_resource.username} NFSHomeDirectory") if (@new_resource.home.nil? || @new_resource.home.empty?)
          if @new_resource.supports[:manage_home]
            validate_home_dir_specification!
            
            if (@current_resource.home == @new_resource.home) && !new_home_exists?
              ditto_home
            elsif !current_home_exists? && !new_home_exists?
              ditto_home
            elsif current_home_exists?
              move_home
            end
          end
          safe_dscl("create /Users/#{@new_resource.username} NFSHomeDirectory '#{@new_resource.home}'")
        end

        def osx_shadow_hash?(string)
          return !! ( string =~ /^[[:xdigit:]]{1240}$/ )
        end

        def osx_salted_sha1?(string)
          return !! ( string =~ /^[[:xdigit:]]{48}$/ )
        end

        def guid
          safe_dscl("read /Users/#{@new_resource.username} GeneratedUID").gsub(/GeneratedUID: /,"").strip
        end

        def shadow_hash_set?
          user_data = safe_dscl("read /Users/#{@new_resource.username}") 
          if user_data =~ /AuthenticationAuthority: / && user_data =~ /ShadowHash/
            true
          else
            false
          end
        end

        def modify_password
          if @new_resource.password
            shadow_hash = nil
            
            Chef::Log.debug("#{new_resource}: updating password")
            if osx_shadow_hash?(@new_resource.password)
              shadow_hash = @new_resource.password.upcase
            else
              if osx_salted_sha1?(@new_resource.password)
                salted_sha1 = @new_resource.password.upcase
              else
                hex_salt = ""
                OpenSSL::Random.random_bytes(10).each_byte { |b| hex_salt << b.to_i.to_s(16) }
                hex_salt = hex_salt.slice(0...8)
                salt = [hex_salt].pack("H*")
                sha1 = ::OpenSSL::Digest::SHA1.hexdigest(salt+@new_resource.password)
                salted_sha1 = (hex_salt+sha1).upcase
              end
              shadow_hash = String.new("00000000"*155)
              shadow_hash[168] = salted_sha1
            end
            
            ::File.open("/var/db/shadow/hash/#{guid}",'w',0600) do |output|
              output.puts shadow_hash
            end
            
            unless shadow_hash_set?
              safe_dscl("append /Users/#{@new_resource.username} AuthenticationAuthority ';ShadowHash;'")
            end
          end
        end

        def load_current_resource
          super
          raise Chef::Exceptions::User, "Could not find binary /usr/bin/dscl for #{@new_resource}" unless ::File.exists?("/usr/bin/dscl")
        end

        def create_user
          dscl_create_user
          dscl_create_comment
          set_uid
          dscl_set_gid
          modify_home
          dscl_set_shell
          modify_password
        end
        
        def manage_user
          dscl_create_user    if diverged?(:username)
          dscl_create_comment if diverged?(:comment)
          set_uid             if diverged?(:uid)
          dscl_set_gid        if diverged?(:uid)
          modify_home         if diverged?(:home)
          dscl_set_shell      if diverged?(:shell)
          modify_password     if diverged?(:password)
        end
        
        def dscl_create_user
          safe_dscl("create /Users/#{@new_resource.username}")              
        end
        
        def dscl_create_comment
          safe_dscl("create /Users/#{@new_resource.username} RealName '#{@new_resource.comment}'")
        end
        
        def dscl_set_gid
          safe_dscl("create /Users/#{@new_resource.username} PrimaryGroupID '#{@new_resource.gid}'")
        end
        
        def dscl_set_shell
          if @new_resource.password || ::File.exists?("#{@new_resource.shell}")
            safe_dscl("create /Users/#{@new_resource.username} UserShell '#{@new_resource.shell}'")
          else
            safe_dscl("create /Users/#{@new_resource.username} UserShell '/usr/bin/false'")
          end
        end
        
        def remove_user
          if @new_resource.supports[:manage_home]
            user_info = safe_dscl("read /Users/#{@new_resource.username}") 
            if nfs_home_match = user_info.match(NFS_HOME_DIRECTORY)
              #nfs_home = safe_dscl("read /Users/#{@new_resource.username} NFSHomeDirectory")
              #nfs_home.gsub!(/NFSHomeDirectory: /,"").gsub!(/\n$/,"")
              nfs_home = nfs_home_match[1]
              FileUtils.rm_rf(nfs_home)
            end
          end
          # remove the user from its groups
          groups = []
          Etc.group do |group|
            groups << group.name if group.mem.include?(@new_resource.username)
          end
          groups.each do |group_name|
            safe_dscl("delete /Groups/#{group_name} GroupMembership '#{@new_resource.username}'")
          end
          # remove user account
          safe_dscl("delete /Users/#{@new_resource.username}")
        end

        def locked?
          user_info = safe_dscl("read /Users/#{@new_resource.username}")
          if auth_authority_md = AUTHENTICATION_AUTHORITY.match(user_info)
            !!(auth_authority_md[1] =~ /DisabledUser/ )
          else
            false
          end
        end
        
        def check_lock
          return @locked = locked?
        end

        def lock_user
          safe_dscl("append /Users/#{@new_resource.username} AuthenticationAuthority ';DisabledUser;'")
        end
        
        def unlock_user
          auth_info = safe_dscl("read /Users/#{@new_resource.username} AuthenticationAuthority")
          auth_string = auth_info.gsub(/AuthenticationAuthority: /,"").gsub(/;DisabledUser;/,"").strip#.gsub!(/[; ]*$/,"")
          safe_dscl("create /Users/#{@new_resource.username} AuthenticationAuthority '#{auth_string}'")
        end
        
        def validate_home_dir_specification!
          unless @new_resource.home =~ /^\//
            raise(Chef::Exceptions::InvalidHomeDirectory,"invalid path spec for User: '#{@new_resource.username}', home directory: '#{@new_resource.home}'") 
          end
        end
        
        def current_home_exists?
          ::File.exist?("#{@current_resource.home}")
        end
        
        def new_home_exists?
          ::File.exist?("#{@new_resource.home}")          
        end
        
        def ditto_home
          skel = "/System/Library/User Template/English.lproj"
          raise(Chef::Exceptions::User,"can't find skel at: #{skel}") unless ::File.exists?(skel)
          shell_out! "ditto '#{skel}' '#{@new_resource.home}'"
          ::FileUtils.chown_R(@new_resource.username,@new_resource.gid.to_s,@new_resource.home)
        end

        def move_home
          Chef::Log.debug("moving #{self} home from #{@current_resource.home} to #{@new_resource.home}")
          
          src = @current_resource.home
          FileUtils.mkdir_p(@new_resource.home)
          files = ::Dir.glob("#{src}/*", ::File::FNM_DOTMATCH) - ["#{src}/.","#{src}/.."]
          ::FileUtils.mv(files,@new_resource.home, :force => true)
          ::FileUtils.rmdir(src)
          ::FileUtils.chown_R(@new_resource.username,@new_resource.gid.to_s,@new_resource.home)
        end
        
        def diverged?(parameter)
          parameter_updated?(parameter) && (not @new_resource.send(parameter).nil?)
        end
        
        def parameter_updated?(parameter)
          not (@new_resource.send(parameter) == @current_resource.send(parameter))
        end
      end
    end
  end
end
