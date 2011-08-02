class Redis
  module Connection
    module CommandHelper

      COMMAND_DELIMITER = "\r\n"

      def build_command(args)
        command = []
        command << "*#{args.size}"

        args.each do |arg|
          arg = arg.to_s
          command << "$#{string_size arg}"
          command << arg
        end

        # Trailing delimiter
        command << ""
        command.join(COMMAND_DELIMITER)
      end

    protected

      if "".respond_to?(:bytesize)
        def string_size(string)
          string.to_s.bytesize
        end
      else
        def string_size(string)
          string.to_s.size
        end
      end

      if defined?(Encoding::default_external)
        def encode(string)
          string.force_encoding(Encoding::default_external)
        end
      else
        def encode(string)
          string
        end
      end
    end
  end
end
