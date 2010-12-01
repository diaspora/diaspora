module Culerity

  class CulerityException < StandardError
    def initialize(message, backtrace)
      super message
      set_backtrace(backtrace)      
    end
  end

  class RemoteObjectProxy
    def initialize(remote_object_id, io)
      @remote_object_id = remote_object_id
      @io = io
    end

    #
    # Commonly used to get the HTML id attribute
    # Use `object_id` to get the local objects' id.
    #
    def id
      send_remote(:id)
    end

    def method_missing(name, *args, &block)
      send_remote(name, *args, &block)
    end

    #
    # Calls the passed method on the remote object with any arguments specified.
    # Behaves the same as <code>Object#send</code>.
    #
    # If you pass it a block then it will append the block as a "lambda { … }".
    # If your block returns a lambda string ("lambda { … }") then it will be passed
    # straight through, otherwise it will be wrapped in a lambda string before sending.
    #
    def send_remote(name, *args, &blk)
      input = [remote_object_id, %Q{"#{name}"}, *args.map{|a| arg_to_string(a)}]
      serialized_block = ", #{block_to_string(&blk)}" if block_given?
      @io << "[[#{input.join(", ")}]#{serialized_block}]\n"
      process_result @io.gets.to_s.strip
    end

    def exit
      @io << '["_exit_"]'
    end

    private

    def process_result(result)
      res = eval result
      if res.first == :return
        res[1]
      elsif res.first == :exception
        raise CulerityException.new("#{res[1]}: #{res[2]}", res[3])
      end
    end

    #
    # Takes a block and either returns the result (if it returns "lambda { … }")
    # or builds the lambda string with the result of the block in it.
    #
    # Returns a string in the format "lambda { … }"
    #
    def block_to_string &block
      result = block.call.to_s.strip
      unless result.is_a?(String) && result[/^lambda\s*(\{|do).+(\}|end)/xm]
        result = "lambda { #{result} }"
      end
      result.gsub("\n", ";")
    end
    
    def arg_to_string(arg)
      if arg.is_a?(Proc)
        block_to_string(&arg)
      else
        arg.inspect
      end
    end

    def remote_object_id
      @remote_object_id
    end
  end
end
