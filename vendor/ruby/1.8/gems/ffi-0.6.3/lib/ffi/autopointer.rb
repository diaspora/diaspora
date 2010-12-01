#
# Copyright (C) 2008, 2009 Wayne Meissner
# Copyright (C) 2008 Mike Dalessio
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the Evan Phoenix nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module FFI
  class AutoPointer < Pointer

    # call-seq:
    #   AutoPointer.new(pointer, method)     => the passed Method will be invoked at GC time
    #   AutoPointer.new(pointer, proc)       => the passed Proc will be invoked at GC time (SEE WARNING BELOW!)
    #   AutoPointer.new(pointer) { |p| ... } => the passed block will be invoked at GC time (SEE WARNING BELOW!)
    #   AutoPointer.new(pointer)             => the pointer's release() class method will be invoked at GC time
    #
    # WARNING: passing a proc _may_ cause your pointer to never be GC'd, unless you're careful to avoid trapping a reference to the pointer in the proc. See the test specs for examples.
    # WARNING: passing a block will cause your pointer to never be GC'd. This is bad.
    #
    # Please note that the safest, and therefore preferred, calling
    # idiom is to pass a Method as the second parameter. Example usage:
    #
    #   class PointerHelper
    #     def self.release(pointer)
    #       ...
    #     end
    #   end
    #
    #   p = AutoPointer.new(other_pointer, PointerHelper.method(:release))
    #
    # The above code will cause PointerHelper#release to be invoked at GC time.
    #
    # The last calling idiom (only one parameter) is generally only
    # going to be useful if you subclass AutoPointer, and override
    # release(), which by default does nothing.
    #
    def initialize(ptr, proc=nil, &block)
      raise TypeError, "Invalid pointer" if ptr.nil? || !ptr.kind_of?(Pointer) \
        || ptr.kind_of?(MemoryPointer) || ptr.kind_of?(AutoPointer)

      @releaser = if proc
                    raise RuntimeError.new("proc must be callable") unless proc.respond_to?(:call)
                    CallableReleaser.new(ptr, proc)

                  else
                    raise RuntimeError.new("no release method defined") unless self.class.respond_to?(:release)
                    DefaultReleaser.new(ptr, self.class)
                  end

      self.parent = ptr
      ObjectSpace.define_finalizer(self, @releaser)
      self
    end

    def free
      @releaser.free
    end

    def autorelease=(autorelease)
      @releaser.autorelease=(autorelease)
    end

    class Releaser
      def initialize(ptr, proc)
        @ptr = ptr
        @proc = proc
        @autorelease = true
      end

      def free
        raise RuntimeError.new("pointer already freed") unless @ptr
        @autorelease = false
        @ptr = nil
        @proc = nil
      end
      
      def autorelease=(autorelease)
        raise RuntimeError.new("pointer already freed") unless @ptr
        @autorelease = autorelease
      end

    end

    class DefaultReleaser < Releaser
      def call(*args)
        @proc.release(@ptr) if @autorelease && @ptr
      end
    end

    class CallableReleaser < Releaser
      def call(*args)
        @proc.call(@ptr) if @autorelease && @ptr
      end
    end

  end

end
