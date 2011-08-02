# = Subexec
# * by Peter Kieltyka
# * http://github/nulayer/subprocess
# 
# === Description
# 
# Subexec is a simple library that spawns an external command with
# an optional timeout parameter. It relies on Ruby 1.9's Process.spawn
# method. Also, it works with synchronous and asynchronous code.
# 
# Useful for libraries that are Ruby wrappers for CLI's. For example,
# resizing images with ImageMagick's mogrify command sometimes stalls
# and never returns control back to the original process. Subexec
# executes mogrify and preempts if gets lost.
# 
# === Usage
# 
# # Print hello
# sub = Subexec.run "echo 'hello' && sleep 3", :timeout => 5
# puts sub.output     # returns: hello
# puts sub.exitstatus # returns: 0
# 
# # Timeout process after a second
# sub = Subexec.run "echo 'hello' && sleep 3", :timeout => 1
# puts sub.output     # returns: 
# puts sub.exitstatus # returns:

class Subexec

  attr_accessor :pid
  attr_accessor :command
  attr_accessor :timeout
  attr_accessor :timer
  attr_accessor :output
  attr_accessor :exitstatus

  def self.run(command, options={})
    sub = new(command, options)
    sub.run!
    sub
  end
  
  def initialize(command, options={})
    self.command  = command
    self.timeout  = options[:timeout] || -1 # default is to never timeout
  end
  
  def run!
    if timeout > 0 && RUBY_VERSION >= '1.9'
      spawn
    else
      exec
    end
  end


  private
  
    def spawn
      r, w = IO.pipe
      self.pid = Process.spawn(command, STDERR=>w, STDOUT=>w)
      w.close

      self.timer = Time.now + timeout
      timed_out = false

      loop do
        begin
          flags = (timeout > 0 ? Process::WUNTRACED|Process::WNOHANG : 0)
          ret = Process.waitpid(pid, flags)
        rescue Errno::ECHILD
          break
        end

        break if ret == pid
        sleep 0.01
        if Time.now > timer
          timed_out = true
          break
        end
      end

      if timed_out
        # The subprocess timed out -- kill it
        Process.kill(9, pid) rescue Errno::ESRCH
        self.exitstatus = nil
      else
        # The subprocess exited on its own
        self.exitstatus = $?.exitstatus
        self.output = r.readlines.join("")
      end
      r.close
      
      self
    end
  
    def exec
      self.output = `#{command} 2>&1`
      self.exitstatus = $?.exitstatus
    end

end

