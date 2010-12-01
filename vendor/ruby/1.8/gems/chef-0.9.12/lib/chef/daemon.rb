#
# Author:: AJ Christensen (<aj@junglist.gen.nz>)
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

# I love you Merb (lib/merb-core/server.rb)

require 'chef/config'
require 'etc'

class Chef
  class Daemon
    class << self
      attr_accessor :name

      # Daemonize the current process, managing pidfiles and process uid/gid
      #
      # === Parameters
      # name<String>:: The name to be used for the pid file
      #
      def daemonize(name)
        @name = name
        pid = pid_from_file
        unless running?
          remove_pid_file()
          Chef::Log.info("Daemonizing..")
          begin
            exit if fork
            Process.setsid
            exit if fork
            Chef::Log.info("Forked, in #{Process.pid}. Priveleges: #{Process.euid} #{Process.egid}")
            File.umask Chef::Config[:umask]
            $stdin.reopen("/dev/null")
            $stdout.reopen("/dev/null", "a")
            $stderr.reopen($stdout)
            save_pid_file
            at_exit { remove_pid_file }
          rescue NotImplementedError => e
            Chef::Application.fatal!("There is no fork: #{e.message}")
          end
        else
          Chef::Application.fatal!("Chef is already running pid #{pid}")
        end
      end
  
      # Check if Chef is running based on the pid_file
      # ==== Returns
      # Boolean::
      # True if Chef is running
      # False if Chef is not running
      #
      def running?
        if pid_from_file.nil?
          false
        else
          Process.kill(0, pid_from_file)
          true
        end
      rescue Errno::ESRCH, Errno::ENOENT
        false
      rescue Errno::EACCES => e
        Chef::Application.fatal!("You don't have access to the PID file at #{pid_file}: #{e.message}")
      end
      
      # Gets the pid file for @name
      # ==== Returns
      # String::
      #   Location of the pid file for @name
      def pid_file
         Chef::Config[:pid_file] or "/tmp/#{@name}.pid"
      end
      
      # Suck the pid out of pid_file
      # ==== Returns
      # Integer::
      #   The PID from pid_file
      # nil::
      #   Returned if the pid_file does not exist.
      #
      def pid_from_file
        File.read(pid_file).chomp.to_i
      rescue Errno::ENOENT, Errno::EACCES
        nil
      end
    
      # Store the PID on the filesystem
      # This uses the Chef::Config[:pid_file] option, or "/tmp/name.pid" otherwise
      #
      def save_pid_file
        file = pid_file
        begin
          FileUtils.mkdir_p(File.dirname(file))
        rescue Errno::EACCES => e
          Chef::Application.fatal!("Failed store pid in #{File.dirname(file)}, permission denied: #{e.message}")
        end
      
        begin
          File.open(file, "w") { |f| f.write(Process.pid.to_s) }
        rescue Errno::EACCES => e
          Chef::Application.fatal!("Couldn't write to pidfile #{file}, permission denied: #{e.message}")
        end
      end
    
      # Delete the PID from the filesystem
      def remove_pid_file
        FileUtils.rm(pid_file) if File.exists?(pid_file)
      end
           
      # Change process user/group to those specified in Chef::Config
      #
      def change_privilege
        Dir.chdir("/")

        if Chef::Config[:user] and Chef::Config[:group]
          Chef::Log.info("About to change privilege to #{Chef::Config[:user]}:#{Chef::Config[:group]}")
          _change_privilege(Chef::Config[:user], Chef::Config[:group])
        elsif Chef::Config[:user]
          Chef::Log.info("About to change privilege to #{Chef::Config[:user]}")
          _change_privilege(Chef::Config[:user])
        end
      end
    
      # Change privileges of the process to be the specified user and group
      #
      # ==== Parameters
      # user<String>:: The user to change the process to.
      # group<String>:: The group to change the process to.
      #
      # ==== Alternatives
      # If group is left out, the user will be used (changing to user:user)
      #
      def _change_privilege(user, group=user)
        uid, gid = Process.euid, Process.egid

        begin
          target_uid = Etc.getpwnam(user).uid
        rescue ArgumentError => e
          Chef::Application.fatal!("Failed to get UID for user #{user}, does it exist? #{e.message}")
          return false
        end
   
        begin
          target_gid = Etc.getgrnam(group).gid
        rescue ArgumentError => e
          Chef::Application.fatal!("Failed to get GID for group #{group}, does it exist? #{e.message}")
          return false
        end
      
        if (uid != target_uid) or (gid != target_gid)
          Process.initgroups(user, target_gid)
          Process::GID.change_privilege(target_gid)
          Process::UID.change_privilege(target_uid)
        end
        true
      rescue Errno::EPERM => e
        Chef::Application.fatal!("Permission denied when trying to change #{uid}:#{gid} to #{target_uid}:#{target_gid}. #{e.message}")
      end
    end
  end
end
