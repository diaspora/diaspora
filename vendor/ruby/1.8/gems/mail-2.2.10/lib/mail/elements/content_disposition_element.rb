# encoding: utf-8
module Mail
  class ContentDispositionElement # :nodoc:
    
    include Mail::Utilities
    
    def initialize( string )
      parser = Mail::ContentDispositionParser.new
      if tree = parser.parse(cleaned(string))
        @disposition_type = tree.disposition_type.text_value.downcase
        @parameters = tree.parameters
      else
        raise Mail::Field::ParseError, "ContentDispositionElement can not parse |#{string}|\nReason was: #{parser.failure_reason}\n"
      end
    end
    
    def disposition_type
      @disposition_type
    end
    
    def parameters
      @parameters
    end
    
    def cleaned(string)
      string =~ /(.+);\s*$/ ? $1 : string
    end
    
  end
end
