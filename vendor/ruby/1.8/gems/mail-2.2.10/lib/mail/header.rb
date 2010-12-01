# encoding: utf-8
module Mail
  
  # Provides access to a header object.
  # 
  # ===Per RFC2822
  # 
  #  2.2. Header Fields
  # 
  #   Header fields are lines composed of a field name, followed by a colon
  #   (":"), followed by a field body, and terminated by CRLF.  A field
  #   name MUST be composed of printable US-ASCII characters (i.e.,
  #   characters that have values between 33 and 126, inclusive), except
  #   colon.  A field body may be composed of any US-ASCII characters,
  #   except for CR and LF.  However, a field body may contain CRLF when
  #   used in header "folding" and  "unfolding" as described in section
  #   2.2.3.  All field bodies MUST conform to the syntax described in
  #   sections 3 and 4 of this standard.
  class Header
    include Patterns
    include Utilities
    include Enumerable
    
    # Creates a new header object.
    # 
    # Accepts raw text or nothing.  If given raw text will attempt to parse
    # it and split it into the various fields, instantiating each field as
    # it goes.
    # 
    # If it finds a field that should be a structured field (such as content
    # type), but it fails to parse it, it will simply make it an unstructured
    # field and leave it alone.  This will mean that the data is preserved but
    # no automatic processing of that field will happen.  If you find one of
    # these cases, please make a patch and send it in, or at the least, send
    # me the example so we can fix it.
    def initialize(header_text = nil, charset = nil)
      @errors = []
      @charset = charset
      self.raw_source = header_text.to_crlf
      split_header if header_text
    end
    
    # The preserved raw source of the header as you passed it in, untouched
    # for your Regexing glory.
    def raw_source
      @raw_source
    end
    
    # Returns an array of all the fields in the header in order that they
    # were read in.
    def fields
      @fields ||= FieldList.new
    end
    
    #  3.6. Field definitions
    #  
    #   It is important to note that the header fields are not guaranteed to
    #   be in a particular order.  They may appear in any order, and they
    #   have been known to be reordered occasionally when transported over
    #   the Internet.  However, for the purposes of this standard, header
    #   fields SHOULD NOT be reordered when a message is transported or
    #   transformed.  More importantly, the trace header fields and resent
    #   header fields MUST NOT be reordered, and SHOULD be kept in blocks
    #   prepended to the message.  See sections 3.6.6 and 3.6.7 for more
    #   information.
    # 
    # Populates the fields container with Field objects in the order it
    # receives them in.
    #
    # Acceps an array of field string values, for example:
    # 
    #  h = Header.new
    #  h.fields = ['From: mikel@me.com', 'To: bob@you.com']
    def fields=(unfolded_fields)
      @fields = Mail::FieldList.new
      unfolded_fields.each do |field|

        field = Field.new(field, nil, charset)
        field.errors.each { |error| self.errors << error }
        selected = select_field_for(field.name)

        if selected.any? && limited_field?(field.name)
          selected.first.update(field.name, field.value)
        else
          @fields << field
        end
      end

    end
    
    def errors
      @errors
    end
    
    #  3.6. Field definitions
    #  
    #   The following table indicates limits on the number of times each
    #   field may occur in a message header as well as any special
    #   limitations on the use of those fields.  An asterisk next to a value
    #   in the minimum or maximum column indicates that a special restriction
    #   appears in the Notes column.
    #
    #   <snip table from 3.6>
    #
    # As per RFC, many fields can appear more than once, we will return a string
    # of the value if there is only one header, or if there is more than one 
    # matching header, will return an array of values in order that they appear
    # in the header ordered from top to bottom.
    # 
    # Example:
    # 
    #  h = Header.new
    #  h.fields = ['To: mikel@me.com', 'X-Mail-SPAM: 15', 'X-Mail-SPAM: 20']
    #  h['To']          #=> 'mikel@me.com'
    #  h['X-Mail-SPAM'] #=> ['15', '20']
    def [](name)
      name = dasherize(name).downcase
      selected = select_field_for(name)
      case
      when selected.length > 1
        selected.map { |f| f }
      when !selected.blank?
        selected.first
      else
        nil
      end
    end
    
    # Sets the FIRST matching field in the header to passed value, or deletes
    # the FIRST field matched from the header if passed nil
    # 
    # Example:
    # 
    #  h = Header.new
    #  h.fields = ['To: mikel@me.com', 'X-Mail-SPAM: 15', 'X-Mail-SPAM: 20']
    #  h['To'] = 'bob@you.com'
    #  h['To']    #=> 'bob@you.com'
    #  h['X-Mail-SPAM'] = '10000'
    #  h['X-Mail-SPAM'] # => ['15', '20', '10000']
    #  h['X-Mail-SPAM'] = nil
    #  h['X-Mail-SPAM'] # => nil
    def []=(name, value)
      name = dasherize(name)
      fn = name.downcase
      selected = select_field_for(fn)
      
      case
      # User wants to delete the field
      when !selected.blank? && value == nil
        fields.delete_if { |f| selected.include?(f) }
        
      # User wants to change the field
      when !selected.blank? && limited_field?(fn)
        selected.first.update(fn, value)
        
      # User wants to create the field
      else
        # Need to insert in correct order for trace fields
        self.fields << Field.new(name.to_s, value, charset)
      end
    end
    
    def charset
      params = self[:content_type].parameters rescue nil
      if params
        params[:charset]
      else
        @charset
      end
    end
    
    def charset=(val)
      params = self[:content_type].parameters rescue nil
      if params
        params[:charset] = val
      end
      @charset = val
    end
    
    LIMITED_FIELDS   = %w[ date from sender reply-to to cc bcc 
                           message-id in-reply-to references subject
                           return-path content-type mime-version
                           content-transfer-encoding content-description 
                           content-id content-disposition content-location]

    def encoded
      buffer = ''
      fields.each do |field|
        buffer << field.encoded
      end
      buffer
    end

    def to_s
      encoded
    end
    
    def decoded
      raise NoMethodError, 'Can not decode an entire header as there could be character set conflicts, try calling #decoded on the various fields.'
    end

    def field_summary
      fields.map { |f| "<#{f.name}: #{f.value}>" }.join(", ")
    end

    # Returns true if the header has a Message-ID defined (empty or not)
    def has_message_id?
      !fields.select { |f| f.responsible_for?('Message-ID') }.empty?
    end

    # Returns true if the header has a Content-ID defined (empty or not)
    def has_content_id?
      !fields.select { |f| f.responsible_for?('Content-ID') }.empty?
    end

    # Returns true if the header has a Date defined (empty or not)
    def has_date?
      !fields.select { |f| f.responsible_for?('Date') }.empty?
    end

    # Returns true if the header has a MIME version defined (empty or not)
    def has_mime_version?
      !fields.select { |f| f.responsible_for?('Mime-Version') }.empty?
    end

    private
    
    def raw_source=(val)
      @raw_source = val
    end
    
    # 2.2.3. Long Header Fields
    # 
    #  The process of moving from this folded multiple-line representation
    #  of a header field to its single line representation is called
    #  "unfolding". Unfolding is accomplished by simply removing any CRLF
    #  that is immediately followed by WSP.  Each header field should be
    #  treated in its unfolded form for further syntactic and semantic
    #  evaluation.
    def unfold(string)
      string.gsub(/#{CRLF}#{WSP}+/, ' ').gsub(/#{WSP}+/, ' ')
    end
    
    # Returns the header with all the folds removed
    def unfolded_header
      @unfolded_header ||= unfold(raw_source)
    end
    
    # Splits an unfolded and line break cleaned header into individual field
    # strings.
    def split_header
      self.fields = unfolded_header.split(CRLF)
    end
    
    def select_field_for(name)
      fields.select { |f| f.responsible_for?(name.to_s) }
    end
    
    def limited_field?(name)
      LIMITED_FIELDS.include?(name.to_s.downcase)
    end
    
  end
end
