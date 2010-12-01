# encoding: utf-8
module Mail
  class ContentLocationElement # :nodoc:
    
    include Mail::Utilities
    
    def initialize( string )
      parser = Mail::ContentLocationParser.new
      if tree = parser.parse(string)
        @location = tree.location.text_value
      else
        raise Mail::Field::ParseError, "ContentLocationElement can not parse |#{string}|\nReason was: #{parser.failure_reason}\n"
      end
    end
    
    def location
      @location
    end
    
    def to_s(*args)
      location.to_s
    end
    
  end
end
