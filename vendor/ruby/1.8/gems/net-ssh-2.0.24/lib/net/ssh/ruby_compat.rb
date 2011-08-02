require 'thread'

class String
  if RUBY_VERSION < "1.9"
    def getbyte(index)
      self[index]
    end
  end
end

module Net; module SSH
  
  # This class contains miscellaneous patches and workarounds
  # for different ruby implementations.
  class Compat
    
    # A workaround for an IO#select threading bug in certain versions of MRI 1.8.
    # See: http://net-ssh.lighthouseapp.com/projects/36253/tickets/1-ioselect-threading-bug-in-ruby-18
    # The root issue is documented here: http://redmine.ruby-lang.org/issues/show/1993
    if RUBY_VERSION >= '1.9' || RUBY_PLATFORM == 'java'
      def self.io_select(*params)
        IO.select(*params)
      end
    else
      SELECT_MUTEX = Mutex.new
      def self.io_select(*params)
        # It should be safe to wrap calls in a mutex when the timeout is 0
        # (that is, the call is not supposed to block).
        # We leave blocking calls unprotected to avoid causing deadlocks.
        # This should still catch the main case for Capistrano users.
        if params[3] == 0
          SELECT_MUTEX.synchronize do
            IO.select(*params)
          end
        else
          IO.select(*params)
        end
      end
    end
    
  end
  
end; end
