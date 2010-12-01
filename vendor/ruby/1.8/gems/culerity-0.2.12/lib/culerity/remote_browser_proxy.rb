module Culerity
  class RemoteBrowserProxy < RemoteObjectProxy
    def initialize(io, browser_options = {})
      @io = io
      #sets the remote receiver to celerity for the new_browser message.
      @remote_object_id = "celerity".inspect 
      #celerity server will create a new browser which shall receive the remote calls from now on.
      @remote_object_id = new_browser(browser_options).inspect
    end
    
    # 
    # Calls the block until it returns true or +time_to_wait+ is reached.
    # +time_to_wait+ is 30 seconds by default
    # 
    # Returns true upon success
    # Raises Timeout::Error when +time_to_wait+ is reached.
    # 
    def wait_until time_to_wait=30, &block
      Timeout.timeout(time_to_wait) do
        until block.call
          sleep 0.1
        end
      end
      true
    end
    
    # 
    # Calls the block until it doesn't return true or +time_to_wait+ is reached.
    # +time_to_wait+ is 30 seconds by default
    # 
    # Returns true upon success
    # Raises Timeout::Error when +time_to_wait+ is reached.
    # 
    def wait_while time_to_wait=30, &block
      Timeout.timeout(time_to_wait) do
        while block.call
          sleep 0.1
        end
      end
      true
    end
    
    
    #
    # Specify whether to accept or reject all confirm js dialogs
    # for the code in the block that's run.
    # 
    def confirm(bool, &block)
      blk = "lambda { #{bool} }"
      
      self.send_remote(:add_listener, :confirm) { blk }
      block.call
      self.send_remote(:remove_listener, :confirm, lambda {blk})
    end
    
  end
  
  
end
