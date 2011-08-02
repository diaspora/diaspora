module ChildProcess::Windows
  # typedef struct _STARTUPINFO {
  #   DWORD  cb;
  #   LPTSTR lpReserved;
  #   LPTSTR lpDesktop;
  #   LPTSTR lpTitle;
  #   DWORD  dwX;
  #   DWORD  dwY;
  #   DWORD  dwXSize;
  #   DWORD  dwYSize;
  #   DWORD  dwXCountChars;
  #   DWORD  dwYCountChars;
  #   DWORD  dwFillAttribute;
  #   DWORD  dwFlags;
  #   WORD   wShowWindow;
  #   WORD   cbReserved2;
  #   LPBYTE lpReserved2;
  #   HANDLE hStdInput;
  #   HANDLE hStdOutput;
  #   HANDLE hStdError;
  # } STARTUPINFO, *LPSTARTUPINFO;

  class StartupInfo < FFI::Struct
    layout :cb,               :ulong,
           :lpReserved,       :pointer,
           :lpDesktop,        :pointer,
           :lpTitle,          :pointer,
           :dwX,              :ulong,
           :dwY,              :ulong,
           :dwXSize,          :ulong,
           :dwYSize,          :ulong,
           :dwXCountChars,    :ulong,
           :dwYCountChars,    :ulong,
           :dwFillAttribute,  :ulong,
           :dwFlags,          :ulong,
           :wShowWindow,      :ushort,
           :cbReserved2,      :ushort,
           :lpReserved2,      :pointer,
           :hStdInput,        :pointer, # void ptr
           :hStdOutput,       :pointer, # void ptr
           :hStdError,        :pointer # void ptr
  end

  #
  # typedef struct _PROCESS_INFORMATION {
  #   HANDLE hProcess;
  #   HANDLE hThread;
  #   DWORD  dwProcessId;
  #   DWORD  dwThreadId;
  # } PROCESS_INFORMATION, *LPPROCESS_INFORMATION;
  #

  class ProcessInfo < FFI::Struct
    layout :hProcess,    :pointer, # void ptr
           :hThread,     :pointer, # void ptr
           :dwProcessId, :ulong,
           :dwThreadId,  :ulong
  end

  #
  # typedef struct _SECURITY_ATTRIBUTES {
  #   DWORD  nLength;
  #   LPVOID lpSecurityDescriptor;
  #   BOOL   bInheritHandle;
  # } SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;
  #

  class SecurityAttributes < FFI::Struct
    layout :nLength,              :ulong,
           :lpSecurityDescriptor, :pointer, # void ptr
           :bInheritHandle,       :int

    def initialize(opts = {})
      super()

      self[:nLength]              = self.class.size
      self[:lpSecurityDescriptor] = nil
      self[:bInheritHandle]       = opts[:inherit] ? 1 : 0
    end
  end
end