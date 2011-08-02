module ChildProcess::Windows

  FORMAT_MESSAGE_FROM_SYSTEM    = 0x00001000
  FORMAT_MESSAGE_ARGUMENT_ARRAY = 0x00002000

  PROCESS_ALL_ACCESS            = 0x1F0FFF
  PROCESS_QUERY_INFORMATION     = 0x0400
  PROCESS_VM_READ               = 0x0010
  PROCESS_STILL_ACTIVE          = 259

  INFINITE                      = 0xFFFFFFFF

  WIN_SIGINT                    = 2
  WIN_SIGBREAK                  = 3
  WIN_SIGKILL                   = 9

  CTRL_C_EVENT                  = 0
  CTRL_BREAK_EVENT              = 1

  DETACHED_PROCESS              = 0x00000008

  STARTF_USESTDHANDLES          = 0x00000100
  INVALID_HANDLE_VALUE          = 0xFFFFFFFF
  HANDLE_FLAG_INHERIT           = 0x00000001

  DUPLICATE_SAME_ACCESS         = 0x00000002

  module Lib
    enum :wait_status, [ :wait_object_0,  0,
                         :wait_timeout,   0x102,
                         :wait_abandoned, 0x80,
                         :wait_failed,    0xFFFFFFFF ]
  end # Lib
end # ChildProcess::Windows