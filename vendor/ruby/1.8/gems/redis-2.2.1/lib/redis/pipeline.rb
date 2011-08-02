class Redis
  class Pipeline
    attr :commands

    def initialize
      @commands = []
    end

    # Starting with 2.2.1, assume that this method is called with a single
    # array argument. Check its size for backwards compat.
    def call(*args)
      if args.first.is_a?(Array) && args.size == 1
        command = args.first
      else
        command = args
      end

      @commands << command
      nil
    end

    # Assume that this method is called with a single array argument. No
    # backwards compat here, since it was introduced in 2.2.2.
    def call_without_reply(command)
      @commands.push command
      nil
    end

    def call_pipelined(commands, options = {})
      @commands.concat commands
      nil
    end
  end
end
