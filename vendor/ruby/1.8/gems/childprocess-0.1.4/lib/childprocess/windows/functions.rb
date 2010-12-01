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

          si[:hStdOutput] = get_os_file_handle(opts[:stdout].fileno) if opts[:stdout]
          si[:hStdError]  = get_os_file_handle(opts[:stderr].fileno) if opts[:stderr]
        end

        ok = create_process(nil, cmd_ptr, nil, nil, inherit, flags, nil, nil, si, pi)
        ok or raise Error, last_error_message

        close_handle pi[:hProcess]
        close_handle pi[:hThread]

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

      def self.get_os_file_handle(fd_or_io)
        case fd_or_io
        when IO
          handle = _get_osfhandle(fd.fileno)
        when Fixnum
          handle = _get_osfhandle(fd_or_io)
        else
          if fd_or_io.respond_to?(:to_io)
            io = fd_or_io.to_io

            unless io.kind_of?(IO)
              raise TypeError, "expected #to_io to return an instance of IO"
            end

            handle = _get_osfhandle(io.fileno)
          else
            raise TypeError, "invalid type: #{fd_or_io.inspect}"
          end
        end

        if handle == INVALID_HANDLE_VALUE
          raise Error, Lib.last_error_message
        end

        handle
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

      attach_function :_get_osfhandle, :_get_osfhandle, [:int], :long

      # BOOL WINAPI SetHandleInformation(
      #   __in  HANDLE hObject,
      #   __in  DWORD dwMask,
      #   __in  DWORD dwFlags
      # );

      attach_function :set_handle_information, :SetHandleInformation, [:long, :ulong, :ulong], :bool

    end # Lib
  end # Windows
end # ChildProcess
