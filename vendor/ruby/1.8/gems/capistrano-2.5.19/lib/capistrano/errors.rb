module Capistrano
  
  Error = Class.new(RuntimeError)

  CaptureError            = Class.new(Capistrano::Error)
  NoSuchTaskError         = Class.new(Capistrano::Error)
  NoMatchingServersError  = Class.new(Capistrano::Error)
  
  class RemoteError < Error
    attr_accessor :hosts
  end

  ConnectionError     = Class.new(Capistrano::RemoteError)
  TransferError       = Class.new(Capistrano::RemoteError)
  CommandError        = Class.new(Capistrano::RemoteError)
  
  LocalArgumentError  = Class.new(Capistrano::Error)
  
end
