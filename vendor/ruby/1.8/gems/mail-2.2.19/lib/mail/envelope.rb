# encoding: utf-8
# 
# = Mail Envelope
# 
# The Envelope class provides a field for the first line in an
# mbox file, that looks like "From mikel@test.lindsaar.net DATETIME"
# 
# This envelope class reads that line, and turns it into an
# Envelope.from and Envelope.date for your use.
module Mail
  class Envelope < StructuredField
    
    def initialize(*args)
      super(FIELD_NAME, strip_field(FIELD_NAME, args.last))
    end
    
    def tree
      @element ||= Mail::EnvelopeFromElement.new(value)
      @tree ||= @element.tree
    end
    
    def element
      @element ||= Mail::EnvelopeFromElement.new(value)
    end
    
    def date
      ::DateTime.parse("#{element.date_time}")
    end

    def from
      element.address
    end
    
  end
end
