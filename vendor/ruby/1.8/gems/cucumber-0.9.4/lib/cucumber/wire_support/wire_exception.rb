module Cucumber
  module WireSupport
    # Proxy for an exception that occured at the remote end of the wire
    class WireException < StandardError
      module CanSetName
        attr_writer :exception_name
        def to_s
          @exception_name
        end
      end
      
      def initialize(args, host, port)
        super args['message']
        if args['exception']
          self.class.extend(CanSetName)
          self.class.exception_name = "#{args['exception']} from #{host}:#{port}"
        end
        if args['backtrace']
          @backtrace = if args['backtrace'].is_a?(String)
              args['backtrace'].split("\n") # TODO: change cuke4nuke to pass an array instead of a big string
            else
              args['backtrace']
            end
        end
      end
      
      def backtrace
        @backtrace || super
      end
    end
  end
end