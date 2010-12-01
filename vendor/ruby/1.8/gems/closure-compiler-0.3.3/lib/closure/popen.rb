module Closure

  # A slightly modified version of Ruby 1.8's Open3, that doesn't use a
  # grandchild process, and returns the pid of the external process.
  module Popen

    WINDOWS  = RUBY_PLATFORM.match(/(win|w)32$/)
    ONE_NINE = RUBY_VERSION >= "1.9"
    if WINDOWS
      if ONE_NINE
        require 'open3'
      else
        require 'rubygems'
        require 'win32/open3'
      end
    end

    def self.popen(cmd)
      if WINDOWS
        error = nil
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
          yield(stdin, stdout, stderr) if block_given?
          stdout.read unless stdout.closed? or stdout.eof?
          unless stderr.closed?
            stderr.rewind
            error = stderr.read
          end
          return wait_thread.value if wait_thread.is_a? Thread
        end
      else
        # pipe[0] for read, pipe[1] for write
        pw, pr, pe = IO.pipe, IO.pipe, IO.pipe

        pid = fork {
          pw[1].close
          STDIN.reopen(pw[0])
          pw[0].close

          pr[0].close
          STDOUT.reopen(pr[1])
          pr[1].close

          pe[0].close
          STDERR.reopen(pe[1])
          pe[1].close

          exec(cmd)
        }

        pw[0].close
        pr[1].close
        pe[1].close
        pi = [pw[1], pr[0], pe[0]]
        pw[1].sync = true
        begin
          yield(*pi) if block_given?
        ensure
          pi.each{|p| p.close unless p.closed?}
        end
        Process.waitpid pid
      end
      $?
    end

  end
end
