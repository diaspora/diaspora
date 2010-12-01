# encoding: utf-8
# 
# trace           =       [return]
#                         1*received
# 
# return          =       "Return-Path:" path CRLF
# 
# path            =       ([CFWS] "<" ([CFWS] / addr-spec) ">" [CFWS]) /
#                         obs-path
# 
# received        =       "Received:" name-val-list ";" date-time CRLF
# 
# name-val-list   =       [CFWS] [name-val-pair *(CFWS name-val-pair)]
# 
# name-val-pair   =       item-name CFWS item-value
# 
# item-name       =       ALPHA *(["-"] (ALPHA / DIGIT))
# 
# item-value      =       1*angle-addr / addr-spec /
#                          atom / domain / msg-id
# 
module Mail
  class ReceivedField < StructuredField
    
    FIELD_NAME = 'received'
    CAPITALIZED_FIELD = 'Received'
    
    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      super(CAPITALIZED_FIELD, strip_field(FIELD_NAME, value), charset)
      self.parse
      self

    end
    
    def parse(val = value)
      unless val.blank?
        @element = Mail::ReceivedElement.new(val)
      end
    end
    
    def element
      @element ||= Mail::ReceivedElement.new(value)
    end
    
    def date_time
      @datetime ||= ::DateTime.parse("#{element.date_time}")
    end

    def info
      element.info
    end
   
    def formatted_date
        date_time.strftime("%a, %d %b %Y %H:%M:%S ") + date_time.zone.delete(':')
    end
 
    def encoded
      "#{CAPITALIZED_FIELD}: #{info}; #{formatted_date}\r\n"
    end
    
    def decoded
      "#{info}; #{formatted_date}" 
    end
    
  end
end
