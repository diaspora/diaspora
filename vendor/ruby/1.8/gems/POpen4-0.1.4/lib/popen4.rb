require 'rubygems'
require 'platform'

case Platform::OS

# win32/popen4 yields stdin, stdout, stderr and pid, respectively
when :win32

  require 'win32/open3'

  # POpen4 provides the Rubyist a single API across platforms for executing a
  # command in a child process with handles on stdout, stderr, and stdin streams
  # as well as access to the process ID and exit status.
  #
  # Consider the following example (borrowed from Open4):
  #
  #   require 'rubygems'
  #   require 'popen4'
  #
  #   status =
  #     POpen4::popen4("cmd") do |stdout, stderr, stdin, pid|
  #       stdin.puts "echo hello world!"
  #       stdin.puts "echo ERROR! 1>&2"
  #       stdin.puts "exit"
  #       stdin.close
  #
  #       puts "pid        : #{ pid }"
  #       puts "stdout     : #{ stdout.read.strip }"
  #       puts "stderr     : #{ stderr.read.strip }"
  #     end
  #
  #   puts "status     : #{ status.inspect }"
  #   puts "exitstatus : #{ status.exitstatus }"
  #
  module POpen4
    # Starts a new process and hands IO objects representing the subprocess
    # stdout, stderr, stdin streams and the pid (respectively) to the block
    # supplied. If the command could not be started, return nil.
    #
    # The mode argument may be set to t[ext] or b[inary] and is used only on
    # Windows platforms.
    #
    # The stdin stream and/or pid may be omitted from the block parameter list
    # if they are not required.
    def self.popen4(command, mode = "t") # :yields: stdout, stderr, stdin, pid

      err_output = nil
      Open4.popen4(command, mode) do |stdin,stdout,stderr,pid|
        yield stdout, stderr, stdin, pid

        # On windows we will always get an exit status of 3 unless
        # we read to the end of the streams so we do this on all platforms
        # so that our behavior is always the same.
        stdout.read unless stdout.eof?

        # On windows executing a non existent command does not raise an error
        # (as in unix) so on unix we return nil instead of a status object and
        # on windows we try to determine if we couldn't start the command and
        # return nil instead of the Process::Status object.
        stderr.rewind
        err_output = stderr.read
      end

      return $?
    end # def
  end # module


else # unix popen4 yields pid, stdin, stdout and stderr, respectively
  # :enddoc:
  require 'open4'
  module POpen4
    def self.popen4(command, mode = "t")
      begin
        return status = Open4.popen4(command) do |pid,stdin,stdout,stderr|
          yield stdout, stderr, stdin, pid
          # On windows we will always get an exit status of 3 unless
          # we read to the end of the streams so we do this on all platforms
          # so that our behavior is always the same.
          stdout.read unless stdout.eof?
          stderr.read unless stderr.eof?
        end
      rescue Errno::ENOENT => e
        # On windows executing a non existent command does not raise an error
        # (as in unix) so on unix we return nil instead of a status object and
        # on windows we try to determine if we couldn't start the command and
        # return nil instead of the Process::Status object.
        return nil
      end
    end #def
  end #module

end
