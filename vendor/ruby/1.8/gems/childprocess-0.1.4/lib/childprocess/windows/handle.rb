module ChildProcess
  module Windows
    class Handle

      class << self
        private :new

        def open(pid, access = PROCESS_ALL_ACCESS)
          handle = Lib.open_process(access, false, pid)

          if handle.null?
            raise Error, Lib.last_error_message
          end

          h = new(handle, pid)
          return h unless block_given?

          begin
            yield h
          ensure
            h.close
          end
        end
      end

      def initialize(handle, pid)
        unless handle.kind_of?(FFI::Pointer)
          raise TypeError, "invalid handle: #{handle.inspect}"
        end

        if handle.null?
          raise ArgumentError, "handle is null: #{handle.inspect}"
        end

        @pid    = pid
        @handle = handle
        @closed = false
      end

      def exit_code
        code_pointer = FFI::MemoryPointer.new :ulong
        ok = Lib.get_exit_code(@handle, code_pointer)

        if ok
          code_pointer.get_ulong(0)
        else
          close
          raise Error, Lib.last_error_message
        end
      end

      def send(signal)
        case signal
        when 0
          exit_code == PROCESS_STILL_ALIVE
        when WIN_SIGINT
          Lib.generate_console_ctrl_event(CTRL_C_EVENT, @pid)
        when WIN_SIGBREAK
          Lib.generate_console_ctrl_event(CTRL_BREAK_EVENT, @pid)
        when WIN_SIGKILL
          ok = Lib.terminate_process(@handle, @pid)
          ok or raise Error, Lib.last_error_message
        else
          thread_id     = FFI::MemoryPointer.new(:ulong)
          module_handle = Lib.get_module_handle("kernel32")
          proc_address  = Lib.get_proc_address(module_handle, "ExitProcess")

          thread = Lib.create_remote_thread(@handle, 0, 0, proc_address, 0, 0, thread_id)
          thread or raise Error, Lib.last_error_message

          Lib.wait_for_single_object(thread, 5)
          true
        end
      end

      def close
        return if @closed

        Lib.close_handle(@handle)
        @closed = true
      end

      def wait(milliseconds = nil)
        Lib.wait_for_single_object(@handle, milliseconds || INFINITE)
      end

    end # Handle
  end # Windows
end # ChildProcess
