# these are to backport methods from 1.8.7/1.9.1 to 1.8.6

class Object

  unless method_defined?(:tap)
    def tap
      yield self
      self
    end
  end

end

class String



  unless method_defined?(:bytesize)
    def bytesize
      self.size
    end
  end

  unless method_defined?(:bytes)
    def bytes
      require 'enumerator'
      Enumerable::Enumerator.new(self, :each_byte)
    end
  end

end
