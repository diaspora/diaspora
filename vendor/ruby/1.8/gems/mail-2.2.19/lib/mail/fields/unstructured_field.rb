# encoding: utf-8
require 'mail/fields/common/common_field'

module Mail
  # Provides access to an unstructured header field
  #
  # ===Per RFC 2822:
  #  2.2.1. Unstructured Header Field Bodies
  #  
  #     Some field bodies in this standard are defined simply as
  #     "unstructured" (which is specified below as any US-ASCII characters,
  #     except for CR and LF) with no further restrictions.  These are
  #     referred to as unstructured field bodies.  Semantically, unstructured
  #     field bodies are simply to be treated as a single line of characters
  #     with no further processing (except for header "folding" and
  #     "unfolding" as described in section 2.2.3).
  class UnstructuredField
    
    include Mail::CommonField
    include Mail::Utilities
    
    def initialize(name, value, charset = nil)
      self.charset = charset
      @errors = []
      if charset
        self.charset = charset
      else
        if value.to_s.respond_to?(:encoding)
          self.charset = value.to_s.encoding
        else
          self.charset = $KCODE
        end
      end
      self.name = name
      self.value = value
      self
    end
    
    def charset
      @charset
    end
    
    def charset=(val)
      @charset = val
    end

    def errors
      @errors
    end
    
    def encoded
      do_encode(self.name)
    end
    
    def decoded
      do_decode
    end

    def default
      decoded
    end
    
    def parse # An unstructured field does not parse
      self
    end

    private
    
    def do_encode(name)
      value.nil? ? '' : "#{wrapped_value}\r\n"
    end
    
    def do_decode
      result = value.blank? ? nil : Encodings.decode_encode(value, :decode)
      result.encode!(value.encoding || "UTF-8") if RUBY_VERSION >= '1.9' && !result.blank?
      result
    end
    
    # 2.2.3. Long Header Fields
    # 
    #  Each header field is logically a single line of characters comprising
    #  the field name, the colon, and the field body.  For convenience
    #  however, and to deal with the 998/78 character limitations per line,
    #  the field body portion of a header field can be split into a multiple
    #  line representation; this is called "folding".  The general rule is
    #  that wherever this standard allows for folding white space (not
    #  simply WSP characters), a CRLF may be inserted before any WSP.  For
    #  example, the header field:
    #  
    #          Subject: This is a test
    #  
    #  can be represented as:
    #  
    #          Subject: This
    #           is a test
    #  
    #  Note: Though structured field bodies are defined in such a way that
    #  folding can take place between many of the lexical tokens (and even
    #  within some of the lexical tokens), folding SHOULD be limited to
    #  placing the CRLF at higher-level syntactic breaks.  For instance, if
    #  a field body is defined as comma-separated values, it is recommended
    #  that folding occur after the comma separating the structured items in
    #  preference to other places where the field could be folded, even if
    #  it is allowed elsewhere.
    def wrapped_value # :nodoc:
      @folded_line = []
      @unfolded_line = decoded.to_s.split(/[ \t]/)
      fold("#{name}: ".length)
      wrap_lines(name, @folded_line)
    end
   
    # 6.2. Display of 'encoded-word's
    # 
    #  When displaying a particular header field that contains multiple
    #  'encoded-word's, any 'linear-white-space' that separates a pair of
    #  adjacent 'encoded-word's is ignored.  (This is to allow the use of
    #  multiple 'encoded-word's to represent long strings of unencoded text,
    #  without having to separate 'encoded-word's where spaces occur in the
    #  unencoded text.)
    def wrap_lines(name, folded_lines)
      result = []
      index = 0
      result[index] = "#{name}: #{folded_lines.shift}"
      result.concat(folded_lines)
      result.join("\r\n\s")
    end

    def fold(prepend = 0) # :nodoc:
      encoding = @charset.to_s.upcase.gsub('_', '-')
      while !@unfolded_line.empty?
        encoded = false
        limit = 78 - prepend
        line = ""
        while !@unfolded_line.empty?          
          break unless word = @unfolded_line.first.dup
          # Remember whether it was non-ascii before we encode it ('cause then we can't tell anymore)
          non_ascii = word.not_ascii_only?
          encoded_word = encode(word)
          # Skip to next line if we're going to go past the limit
          # Unless this is the first word, in which case we're going to add it anyway
          # Note: This means that a word that's longer than 998 characters is going to break the spec. Please fix if this is a problem for you.
          # (The fix, it seems, would be to use encoded-word encoding on it, because that way you can break it across multiple lines and 
          # the linebreak will be ignored)
          break if !line.empty? && (line.length + encoded_word.length + 1 > limit)
          # If word was the first non-ascii word, we're going to make the entire line encoded and we're going to reduce the limit accordingly
          if non_ascii && !encoded
            encoded = true
            encoded_word_safify!(line)
            limit = limit - 8 - encoding.length  # minus the =?...?Q?...?= part, the possible leading white-space, and the name of the encoding
          end
          # Remove the word from the queue ...
          @unfolded_line.shift
          # ... add it in encoded form to the current line
          line << " " unless line.empty?
          encoded_word_safify!(encoded_word) if encoded
          line << encoded_word          
        end
        # Add leading whitespace if both this and the last line were encoded, because whitespace between two encoded-words is ignored when decoding
        line = " " + line if encoded && @folded_line.last && @folded_line.last.index('=?') == 0
        # Encode the line if necessary
        line = "=?#{encoding}?Q?#{line.gsub(/ /, '_')}?=" if encoded
        # Add the line to the output and reset the prepend
        @folded_line << line
        prepend = 0
      end
    end
        
    def encode(value)
      value.encode!(charset) if defined?(Encoding) && charset
      (value.not_ascii_only? ? [value].pack("M").gsub("=\n", '') : value).gsub("\r", "=0D").gsub("\n", "=0A")
    end
    
    def encoded_word_safify!(value)
      value.gsub!(/"/,  '=22')
      value.gsub!(/\(/, '=28')
      value.gsub!(/\)/, '=29')
      value.gsub!(/\?/, '=3F')
      value.gsub!(/_/,  '=5F')
    end

  end
end
