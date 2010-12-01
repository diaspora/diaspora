module FFI
  def self.errno
    FFI::LastError.error
  end
  def self.errno=(error)
    FFI::LastError.error = error
  end
end