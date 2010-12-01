unless STDIN.respond_to? :getbyte
  class IO
    alias_method :getbyte, :getc
  end

  class StringIO
    alias_method :getbyte, :getc
  end
end

unless "".respond_to? :each_line
  # Not a perfect translation, but sufficient for our needs.
  class String
    alias_method :each_line, :each
  end
end
