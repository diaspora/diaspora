module Mongrel
  # This class implements a simple way of constructing the HTTP headers dynamically
  # via a Hash syntax.  Think of it as a write-only Hash.  Refer to HttpResponse for
  # information on how this is used.
  #
  # One consequence of this write-only nature is that you can write multiple headers
  # by just doing them twice (which is sometimes needed in HTTP), but that the normal
  # semantics for Hash (where doing an insert replaces) is not there.
  class HeaderOut
    attr_reader :out
    attr_accessor :allowed_duplicates

    def initialize(out)
      @sent = {}
      @allowed_duplicates = {"Set-Cookie" => true, "Set-Cookie2" => true,
        "Warning" => true, "WWW-Authenticate" => true}
      @out = out
    end

    # Simply writes "#{key}: #{value}" to an output buffer.
    def[]=(key,value)
      if not @sent.has_key?(key) or @allowed_duplicates.has_key?(key)
        @sent[key] = true
        @out.write(Const::HEADER_FORMAT % [key, value])
      end
    end
  end
end