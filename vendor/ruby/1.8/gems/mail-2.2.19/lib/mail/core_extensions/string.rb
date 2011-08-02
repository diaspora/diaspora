# encoding: utf-8
class String #:nodoc:
  def to_crlf
    gsub(/\n|\r\n|\r/) { "\r\n" }
  end

  def to_lf
    gsub(/\n|\r\n|\r/) { "\n" }
  end

  unless method_defined?(:ascii_only?)
    # Provides all strings with the Ruby 1.9 method of .ascii_only? and
    # returns true or false
    US_ASCII_REGEXP = %Q{\x00-\x7f}
    def ascii_only?
      !(self =~ /[^#{US_ASCII_REGEXP}]/)
    end
  end
  
  def not_ascii_only?
    !ascii_only?
  end

  unless method_defined?(:bytesize)
    alias :bytesize :length
  end
end
