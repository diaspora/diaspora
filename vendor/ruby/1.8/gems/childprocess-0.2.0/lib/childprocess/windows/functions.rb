module ChildProcess
  module Windows
    module Lib

      def self.create_proc(cmd, opts = {})
        cmd_ptr = FFI::MemoryPointer.from_string cmd

        flags   = 0
        inherit = !!opts[:inherit]

        flags |= DETACHED_PROCESS if opts[:detach]

        si = StartupInfo.new
        pi = ProcessInfo.new

        if opts[:stdout] || opts[:stderr]
          si[:dwFlags] ||= 0
          si[:dwFlags] |= STARTF_USESTDHANDLES
          inherit = true

          si[:hStdOutput] = handle_for(opts[:stdout].fileno) if opts[:stdout]
          si[:hStdError]  = handle_for(opts[:stderr].fileno) if opts[:stderr]
        end

        if opts[:duplex]
          read_pipe_ptr  = FFI::MemoryPointer.new(:pointer)
          write_pipe_ptr = FFI::MemoryPointer.new(:pointer)
          sa         = SecurityAttributes.new(:inherit => true)

          ok = create_pipe(read_pipe_ptr, write_pipe_ptr, sa, 0)
          ok or raise Error, last_error_message

          read_pipe = read_pipe_ptr.read_pointer
          write_pipe = write_pipe_ptr.read_pointer

          si[:hStdInput] = read_pipe
        end

        ok = create_process(nil, cmd_ptr, nil, nil, inherit, flags, nil, nil, si, pi)
        ok or raise Error, last_error_message

        close_handle pi[:hProcess]
        close_handle pi[:hThread]

        if opts[:duplex]
          opts[:stdin] = io_for(duplicate_handle(write_pipe), File::WRONLY)
          close_handle read_pipe
          close_handle write_pipe
        end

        pi[:dwProcessId]
      end

      def self.last_error_message
        errnum = get_last_error
        buf = FFI::MemoryPointer.new :char, 512

        size = format_message(
          FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ARGUMENT_ARRAY,
          nil, errnum, 0, buf, buf.size, nil
        )

        buf.read_string(size).strip
      end

      def self.handle_for(fd_or_io)
        case fd_or_io
        when IO
          handle = get_osfhandle(fd.fileno)
        when Fixnum
          handle = get_osfhandle(fd_or_io)
        else
          if fd_or_io.respond_to?(:to_io)
            io = fd_or_io.to_io

            unless io.kind_of?(IO)
              raise TypeError, "expected #to_io to return an instance of IO"
            end

            handle = get_osfhandle(io.fileno)
          else
            raise TypeError, "invalid type: #{fd_or_io.inspect}"
          end
        end

        if handle == INVALID_HANDLE_VALUE
          raise Error, last_error_message
        end

        handle
      end

      def self.io_for(handle, flags = File::RDONLY)
        fd = open_osfhandle(handle, flags)
        if fd == -1
          raise Error, last_error_message
        end

        ::IO.for_fd fd, flags
      end

      def self.duplicate_handle(handle)
        dup  = FFI::MemoryPointer.new(:pointer)
        proc = current_process

        ok = _duplicate_handle(
          proc, handle, proc, dup, 0, false, DUPLICATE_SAME_ACCESS)

        ok or raise Error, last_error_message

        dup.read_pointer
      ensure
        close_handle proc
      end

      #
      # BOOL WINAPI CreateProcess(
      #   __in_opt     LPCTSTR lpApplicationName,
      #   __inout_opt  LPTSTR lpCommandLine,
      #   __in_opt     LPSECURITY_ATTRIBUTES lpProcessAttributes,
      #   __in_opt     LPSECURITY_ATTRIBUTES lpThreadAttributes,
      #   __in         BOOL bInheritHandles,
      #   __in         DWORD dwCreationFlags,
      #   __in_opt     LPVOID lpEnvironment,
      #   __in_opt     LPCTSTR lpCurrentDirectory,
      #   __in         LPSTARTUPINFO lpStartupInfo,
      #   __out        LPPROCESS_INFORMATION lpProcessInformation
      # );
      #

      attach_function :create_process, :CreateProcessA, [
                        :pointer,
                        :pointer,
                        :pointer,
                        :pointer,
                        :bool,
                        :ulong,
                        :pointer,
                        :pointer,
                        :pointer,
                        :pointer],
                        :bool

      #
      # DWORD WINAPI GetLastError(void);
      #

      attach_function :get_last_error, :GetLastError, [], :ulong

      #
      #   DWORD WINAPI FormatMessage(
      #   __in      DWORD dwFlags,
      #   __in_opt  LPCVOID lpSource,
      #   __in      DWORD dwMessageId,
      #   __in      DWORD dwLanguageId,
      #   __out     LPTSTR lpBuffer,
      #   __in      DWORD nSize,
      #   __in_opt  va_list *Arguments
      # );
      #

      attach_function :format_message, :FormatMessageA, [
                        :ulong,
                        :pointer,
                        :ulong,
                        :ulong,
                        :pointer,
                        :ulong,
                        :pointer],
                        :ulong


      attach_function :close_handle, :CloseHandle, [:pointer], :bool

      #
      # HANDLE WINAPI OpenProcess(
      #   __in  DWORD dwDesiredAccess,
      #   __in  BOOL bInheritHandle,
      #   __in  DWORD dwProcessId
      # );
      #

      attach_function :open_process, :OpenProcess, [:ulong, :bool, :ulong], :pointer

      #
      # DWORD WINAPI WaitForSingleObject(
      #   __in  HANDLE hHandle,
      #   __in  DWORD dwMilliseconds
      # );
      #

      attach_function :wait_for_single_object, :WaitForSingleObject, [:pointer, :ulong], :wait_status

      #
      # BOOL WINAPI GetExitCodeProcess(
      #   __in   HANDLE hProcess,
      #   __out  LPDWORD lpExitCode
      # );
      #

      attach_function :get_exit_code, :GetExitCodeProcess, [:pointer, :pointer], :bool

      #
      # BOOL WINAPI GenerateConsoleCtrlEvent(
      #   __in  DWORD dwCtrlEvent,
      #   __in  DWORD dwProcessGroupId
      # );
      #

      attach_function :generate_console_ctrl_event, :GenerateConsoleCtrlEvent, [:ulong, :ulong], :bool

      #
      # BOOL WINAPI TerminateProcess(
      #   __in  HANDLE hProcess,
      #   __in  UINT uExitCode
      # );
      #

      attach_function :terminate_process, :TerminateProcess, [:pointer, :uint], :bool

      #
      # long _get_osfhandle(
      #    int fd
      # );
      #

      attach_function :get_osfhandle, :_get_osfhandle, [:int], :long

      #
      # int _open_osfhandle (
      #    intptr_t osfhandle,
      #    int flags
      # );
      #

      attach_function :open_osfhandle, :_open_osfhandle, [:pointer, :int], :int

      # BOOL WINAPI SetHandleInformation(
      #   __in  HANDLE hObject,
      #   __in  DWORD dwMask,
      #   __in  DWORD dwFlags
      # );

      attach_function :set_handle_information, :SetHandleInformation, [:long, :ulong, :ulong], :bool

      # BOOL WINAPI CreatePipe(
      #   __out     PHANDLE hReadPipe,
      #   __out     PHANDLE hWritePipe,
      #   __in_opt  LPSECURITY_ATTRIBUTES lpPipeAttributes,
      #   __in      DWORD nSize
      # );

      attach_function :create_pipe, :CreatePipe, [:pointer, :pointer, :pointer, :ulong], :bool

      #
      # HANDLE WINAPI GetCurrentProcess(void);
      #

      attach_function :current_process, :GetCurrentProcess, [], :pointer

      #
      # BOOL WINAPI DuplicateHandle(
      #   __in   HANDLE hSourceProcessHandle,
      #   __in   HANDLE hSourceHandle,
      #   __in   HANDLE hTargetProcessHandle,
      #   __out  LPHANDLE lpTargetHandle,
      #   __in   DWORD dwDesiredAccess,
      #   __in   BOOL bInheritHandle,
      #   __in   DWORD dwOptions
      # );
      #

      attach_function :_duplicate_handle, :DuplicateHandle, [
                         :pointer,
                         :pointer,
                         :pointer,
                         :pointer,
                         :ulong,
                         :bool,
                         :ulong
                      ], :bool
    end # Lib
  end # Windows
end # ChildProcess
