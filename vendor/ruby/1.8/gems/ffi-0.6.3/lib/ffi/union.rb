require 'ffi/struct'

module FFI

  class Union < FFI::Struct
    def self.builder
      b = StructLayoutBuilder.new
      b.union = true
      b
    end
  end
end
