module Mail
  class AttachmentsList < Array

    def initialize(parts_list)
      @parts_list = parts_list
      @content_disposition_type = 'attachment'
      parts_list.map { |p|
        if p.content_type == "message/rfc822"
          Mail.new(p.body).attachments
        elsif p.parts.empty?
          p if p.attachment?
        else
          p.attachments
        end
      }.flatten.compact.each { |a| self << a }
      self
    end

    def inline
      @content_disposition_type = 'inline'
      self
    end

    # Returns the attachment by filename or at index.
    #
    # mail.attachments['test.png'] = File.read('test.png')
    # mail.attachments['test.jpg'] = File.read('test.jpg')
    #
    # mail.attachments['test.png'].filename #=> 'test.png'
    # mail.attachments[1].filename          #=> 'test.jpg'
    def [](index_value)
      if index_value.is_a?(Fixnum)
        self.fetch(index_value)
      else
        self.select { |a| a.filename == index_value }.first
      end
    end

    def []=(name, value)
      default_values = { :content_type => "#{set_mime_type(name)}; filename=\"#{name}\"",
                         :content_transfer_encoding => "#{guess_encoding}",
                         :content_disposition => "#{@content_disposition_type}; filename=\"#{name}\"" }

      if value.is_a?(Hash)

        default_values[:body] = value.delete(:content) if value[:content]

        default_values[:body] = value.delete(:data) if value[:data]

        encoding = value.delete(:transfer_encoding) || value.delete(:encoding)
        if encoding
          if Mail::Encodings.defined? encoding
            default_values[:content_transfer_encoding] = encoding
          else
            raise "Do not know how to handle Content Transfer Encoding #{encoding}, please choose either quoted-printable or base64"
          end
        end

        if value[:mime_type]
          default_values[:content_type] = value.delete(:mime_type)
          @mime_type = MIME::Types[default_values[:content_type]].first
          default_values[:content_transfer_encoding] = guess_encoding
        end

        hash = default_values.merge(value)
      else
        default_values[:body] = value
        hash = default_values
      end

      if hash[:body].respond_to? :force_encoding and hash[:body].respond_to? :valid_encoding?
        if not hash[:body].valid_encoding? and default_values[:content_transfer_encoding].downcase == "binary"
          hash[:body].force_encoding("BINARY")
        end
      end
      
      attachment = Part.new(hash)
      attachment.add_content_id(hash[:content_id])

      @parts_list << attachment
    end

    # Uses the mime type to try and guess the encoding, if it is a binary type, or unknown, then we
    # set it to binary, otherwise as set to plain text
    def guess_encoding
      if @mime_type && !@mime_type.binary?
        "7bit"
      else
        "binary"
      end
    end

    def set_mime_type(filename)
      # Have to do this because MIME::Types is not Ruby 1.9 safe yet
      if RUBY_VERSION >= '1.9'
        new_file = String.new(filename).force_encoding(Encoding::BINARY)
        ext = new_file.split('.'.force_encoding(Encoding::BINARY)).last
        filename = "file.#{ext}".force_encoding('US-ASCII')
      end
      @mime_type = MIME::Types.type_for(filename).first
    end

  end
end

