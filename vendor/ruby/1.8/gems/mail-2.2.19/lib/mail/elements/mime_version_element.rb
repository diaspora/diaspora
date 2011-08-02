# encoding: utf-8
module Mail
  class MimeVersionElement
    
    include Mail::Utilities
    
    def initialize( string )
      parser = Mail::MimeVersionParser.new
      if tree = parser.parse(string)
        @major = tree.major.text_value
        @minor = tree.minor.text_value
      else
        raise Mail::Field::ParseError, "MimeVersionElement can not parse |#{string}|\nReason was: #{parser.failure_reason}\n"
      end
    end
    
    def major
      @major
    end
    
    def minor
      @minor
    end
    
  end
end
