#--
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

require 'etc'
require 'tmpdir'
require 'chef/log'
require 'fcntl'
require 'chef/exceptions'

class Chef

  # == Chef::ShellOut
  # Provides a simplified interface to shelling out yet still collecting both
  # standard out and standard error and providing full control over environment,
  # working directory, uid, gid, etc.
  # 
  # No means for passing input to the subprocess is provided, nor is there any
  # way to inspect the output of the command as it is being read. If you need 
  # to do that, you have to use popen4 (in Chef::Mixin::Command)
  #
  # === Platform Support
  # Chef::ShellOut uses Kernel.fork() and is therefore unsuitable for Windows
  # or jruby.
  class ShellOut
    READ_WAIT_TIME = 0.01
    READ_SIZE = 4096
    DEFAULT_READ_TIMEOUT = 60
    DEFAULT_ENVIRONMENT = {'LC_ALL' => 'C'}
    
    attr_accessor :user, :group, :cwd, :valid_exit_codes
    attr_reader :command, :umask, :environment
    attr_writer :timeout
    attr_reader :execution_time
    
    attr_reader :stdout, :stderr, :status
    
    attr_reader :stdin_pipe, :stdout_pipe, :stderr_pipe, :process_status_pipe
    
    # === Arguments:
    # Takes a single command, or a list of command fragments. These are used
    # as arguments to Kernel.exec. See the Kernel.exec documentation for more
    # explanation of how arguments are evaluated. The last argument can be an
    # options Hash.
    # === Options:
    # If the last argument is a Hash, it is removed from the list of args passed
    # to exec and used as an options hash. The following options are available:
    # * +user+: the user the commmand should run as. if an integer is given, it is
    #   used as a uid. A string is treated as a username and resolved to a uid
    #   with Etc.getpwnam
    # * +group+: the group the command should run as. works similarly to +user+
    # * +cwd+: the directory to chdir to before running the command
    # * +umask+: a umask to set before running the command. If given as an Integer,
    #   be sure to use two leading zeros so it's parsed as Octal. A string will
    #   be treated as an octal integer
    # * +returns+:  one or more Integer values to use as valid exit codes for the
    #   subprocess. This only has an effect if you call +error!+ after
    #   +run_command+.
    # * +environment+: a Hash of environment variables to set before the command
    #   is run. By default, the environment will *always* be set to 'LC_ALL' => 'C'
    #   to prevent issues with multibyte characters in Ruby 1.8. To avoid this,
    #   use :environment => nil for *no* extra environment settings, or
    #   :environment => {'LC_ALL'=>nil, ...} to set other environment settings
    #   without changing the locale.
    # * +timeout+: a Numeric value for the number of seconds to wait on the
    #   child process before raising an Exception. This is calculated as the
    #   total amount of time that ShellOut waited on the child process without
    #   receiving any output (i.e., IO.select returned nil). Default is 60
    #   seconds. Note: the stdlib Timeout library is not used.
    # === Examples:
    # Invoke find(1) to search for .rb files:
    #   find = Chef::ShellOut.new("find . -name '*.rb'")
    #   find.run_command
    #   # If all went well, the results are on +stdout+
    #   puts find.stdout
    #   # find(1) prints diagnostic info to STDERR:
    #   puts "error messages" + find.stderr
    #   # Raise an exception if it didn't exit with 0
    #   find.error!
    # Run a command as the +www+ user with no extra ENV settings from +/tmp+
    #   cmd = Chef::ShellOut.new("apachectl", "start", :user => 'www', :env => nil, :cwd => '/tmp')
    #   cmd.run_command # etc.
    def initialize(*command_args)
      @stdout, @stderr = '', ''
      @environment = DEFAULT_ENVIRONMENT
      @cwd = Dir.tmpdir
      @valid_exit_codes = [0]

      if command_args.last.is_a?(Hash)
        parse_options(command_args.pop)
      end
      
      @command = command_args.size == 1 ? command_args.first : command_args
    end
    
    def umask=(new_umask)
      @umask = (new_umask.respond_to?(:oct) ? new_umask.oct : new_umask.to_i) & 007777
    end
    
    def uid
      return nil unless user
      user.kind_of?(Integer) ? user : Etc.getpwnam(user.to_s).uid
    end
    
    def gid
      return nil unless group
      group.kind_of?(Integer) ? group : Etc.getgrnam(group.to_s).gid
    end
    
    def timeout
      @timeout || DEFAULT_READ_TIMEOUT
    end
    
    # Creates a String showing the output of the command, including a banner
    # showing the exact command executed. Used by +invalid!+ to show command
    # results when the command exited with an unexpected status.
    def format_for_exception
      msg = ""
      msg << "---- Begin output of #{command} ----\n"
      msg << "STDOUT: #{stdout.strip}\n"
      msg << "STDERR: #{stderr.strip}\n"
      msg << "---- End output of #{command} ----\n"
      msg << "Ran #{command} returned #{status.exitstatus}" if status
      msg
    end
    
    def exitstatus
      @status && @status.exitstatus
    end
    
    # Run the command, writing the command's standard out and standard error
    # to +stdout+ and +stderr+, and saving its exit status object to +status+
    # === Returns
    # returns   +self+; +stdout+, +stderr+, +status+, and +exitstatus+ will be
    # populated with results of the command
    # === Raises
    # * Errno::EACCES  when you are not privileged to execute the command
    # * Errno::ENOENT  when the command is not available on the system (or not
    #   in the current $PATH)
    # * Chef::Exceptions::CommandTimeout  when the command does not complete
    #   within +timeout+ seconds (default: 60s)
    def run_command
      Chef::Log.debug("sh(#{@command})")
      @child_pid = fork_subprocess
      
      configure_parent_process_file_descriptors
      propagate_pre_exec_failure
        
      @result = nil
      @execution_time = 0
     
      # Ruby 1.8.7 and 1.8.6 from mid 2009 try to allocate objects during GC
      # when calling IO.select and IO#read. Some OS Vendors are not interested
      # in updating their ruby packages (Apple, *cough*) and we *have to*
      # make it work. So I give you this epic hack:
      GC.disable
      until @status
        ready = IO.select(open_pipes, nil, nil, READ_WAIT_TIME)
        unless ready
          @execution_time += READ_WAIT_TIME
          if @execution_time >= timeout && !@result
            raise Chef::Exceptions::CommandTimeout, "command timed out:\n#{format_for_exception}"
          end
        end
        
        if ready && ready.first.include?(child_stdout)
          read_stdout_to_buffer
        end
        if ready && ready.first.include?(child_stderr)
          read_stderr_to_buffer
        end
        
        unless @status
          # make one more pass to get the last of the output after the
          # child process dies
          if results = Process.waitpid2(@child_pid, Process::WNOHANG)
            @status = results.last
            redo
          end
        end
      end
      self
    rescue Exception
      # do our best to kill zombies
      Process.waitpid2(@child_pid, Process::WNOHANG) rescue nil
      raise
    ensure
      # no matter what happens, turn the GC back on, and hope whatever busted
      # version of ruby we're on doesn't allocate some objects during the next
      # GC run.
      GC.enable
      close_all_pipes
    end
    
    # Checks the +exitstatus+ against the set of +valid_exit_codes+. If 
    # +exitstatus+ is not in the list of +valid_exit_codes+, calls +invalid!+,
    # which raises an Exception.
    # === Returns
    # nil::: always returns nil when it does not raise
    # === Raises
    # Chef::Exceptions::ShellCommandFailed::: via +invalid!+
    def error!
      unless Array(valid_exit_codes).include?(exitstatus)
        invalid!("Expected process to exit 0, but it exited with #{exitstatus}")
      end
    end

    # Raises a Chef::Exceptions::ShellCommandFailed exception, appending the
    # command's stdout, stderr, and exitstatus to the exception message.
    # === Arguments
    # +msg+:  A String to use as the basis of the exception message. The
    # default explanation is very generic, providing a more informative message
    # is highly encouraged.
    # === Raises
    # Chef::Exceptions::ShellCommandFailed  always
    def invalid!(msg=nil)
      msg ||= "Command produced unexpected results"
      raise Chef::Exceptions::ShellCommandFailed, msg + "\n" + format_for_exception
    end
    
    def inspect
      "<#{self.class.name}##{object_id}: command: '#@command' process_status: #{@status.inspect} " +
      "stdout: '#{stdout.strip}' stderr: '#{stderr.strip}' child_pid: #{@child_pid.inspect} " + 
      "environment: #{@environment.inspect} timeout: #{timeout} user: #@user group: #@group working_dir: #@cwd >"
    end

    private
    
    def parse_options(opts)
      opts.each do |option, setting|
        case option.to_s
        when 'cwd'
          self.cwd = setting
        when 'user'
          self.user = setting
        when 'group'
          self.group = setting
        when 'umask'
          self.umask = setting
        when 'timeout'
          self.timeout = setting
        when 'returns'
          self.valid_exit_codes = Array(setting)
        when 'environment', 'env'
          # passing :environment => nil means don't set any new ENV vars
          setting.nil? ? @environment = {} : @environment.merge!(setting)
        else
          raise Chef::Exceptions::InvalidCommandOption, "option '#{option.inspect}' is not a valid option for #{self.class.name}"
        end
      end
    end
    
    def set_user
      if user
        Process.euid = uid
        Process.uid = uid
      end
    end 
    
    def set_group
      if group
        Process.egid = gid
        Process.gid = gid
      end
    end
    
    def set_environment
      environment.each do |env_var,value|
        ENV[env_var] = value
      end
    end
    
    def set_umask
      File.umask(umask) if umask
    end
    
    def initialize_ipc
      @stdout_pipe, @stderr_pipe, @process_status_pipe = IO.pipe, IO.pipe, IO.pipe
      @process_status_pipe.last.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
    end
    
    def child_stdout
      @stdout_pipe[0]
    end
    
    def child_stderr
      @stderr_pipe[0]
    end
    
    def child_process_status
      @process_status_pipe[0]
    end
    
    def close_all_pipes
      child_stdout.close  unless child_stdout.closed?
      child_stderr.close  unless child_stderr.closed?
      child_process_status.close unless child_process_status.closed?
    end
    
    # replace stdout, and stderr with pipes to the parent, and close the
    # reader side of the error marshaling side channel. Close STDIN so when we
    # exec, the new program will know it's never getting input ever.
    def configure_subprocess_file_descriptors
      process_status_pipe.first.close
      
      # HACK: for some reason, just STDIN.close isn't good enough when running
      # under ruby 1.9.2, so make it good enough:
      stdin_reader, stdin_writer = IO.pipe
      stdin_writer.close
      STDIN.reopen stdin_reader
      stdin_reader.close

      stdout_pipe.first.close
      STDOUT.reopen stdout_pipe.last
      stdout_pipe.last.close

      stderr_pipe.first.close
      STDERR.reopen stderr_pipe.last
      stderr_pipe.last.close

      STDOUT.sync = STDERR.sync = true
    end
    
    def configure_parent_process_file_descriptors
      # Close the sides of the pipes we don't care about
      stdout_pipe.last.close
      stderr_pipe.last.close
      process_status_pipe.last.close
      # Get output as it happens rather than buffered
      child_stdout.sync = true
      child_stderr.sync = true

      true
    end
    
    # Some patch levels of ruby in wide use (in particular the ruby 1.8.6 on OSX)
    # segfault when you IO.select a pipe that's reached eof. Weak sauce.
    def open_pipes
      @open_pipes ||= [child_stdout, child_stderr]
    end

    def read_stdout_to_buffer
      while chunk = child_stdout.read_nonblock(READ_SIZE)
        @stdout << chunk
      end
    rescue Errno::EAGAIN
    rescue EOFError
      open_pipes.delete_at(0)
    end
    
    def read_stderr_to_buffer
      while chunk = child_stderr.read_nonblock(READ_SIZE)
        @stderr << chunk
      end
    rescue Errno::EAGAIN
    rescue EOFError
      open_pipes.delete_at(1)
    end
    
    def fork_subprocess
      initialize_ipc
      
      fork do
        configure_subprocess_file_descriptors
        
        set_user
        set_group
        set_environment
        set_umask

        begin
          command.kind_of?(Array) ? exec(*command) : exec(command)
          
          raise 'forty-two' # Should never get here
        rescue Exception => e
          Marshal.dump(e, process_status_pipe.last)
          process_status_pipe.last.flush
        end
        process_status_pipe.last.close unless (process_status_pipe.last.closed?)
        exit!
      end
    end
    
    # Attempt to get a Marshaled error from the side-channel.
    # If it's there, un-marshal it and raise. If it's not there,
    # assume everything went well.
    def propagate_pre_exec_failure
      begin
        e = Marshal.load child_process_status
        raise(Exception === e ? e : "unknown failure: #{e.inspect}")
      rescue EOFError # If we get an EOF error, then the exec was successful
        true
      ensure
        child_process_status.close
      end
    end
    
  end
end
