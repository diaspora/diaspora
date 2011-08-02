module Nokogiri
  module HTML
    class Document < Nokogiri::XML::Document
      ###
      # Get the meta tag encoding for this document.  If there is no meta tag,
      # then nil is returned
      def meta_encoding
        return nil unless meta = css('meta').find { |node|
          node['http-equiv'] =~ /Content-Type/i
        }

        /charset\s*=\s*([\w-]+)/i.match(meta['content'])[1]
      end

      ###
      # Set the meta tag encoding for this document.  If there is no meta 
      # content tag, nil is returned and the encoding is not set.
      def meta_encoding= encoding
        return nil unless meta = css('meta').find { |node|
          node['http-equiv'] =~ /Content-Type/i
        }

        meta['content'] = "text/html; charset=%s" % encoding
        encoding
      end

      ####
      # Serialize Node using +options+.  Save options can also be set using a
      # block. See SaveOptions.
      #
      # These two statements are equivalent:
      #
      #  node.serialize(:encoding => 'UTF-8', :save_with => FORMAT | AS_XML)
      #
      # or
      #
      #   node.serialize(:encoding => 'UTF-8') do |config|
      #     config.format.as_xml
      #   end
      #
      def serialize options = {}, &block
        options[:save_with] ||= XML::Node::SaveOptions::FORMAT |
            XML::Node::SaveOptions::AS_HTML |
            XML::Node::SaveOptions::NO_DECLARATION |
            XML::Node::SaveOptions::NO_EMPTY_TAGS
        super
      end

      ####
      # Create a Nokogiri::XML::DocumentFragment from +tags+
      def fragment tags = nil
        DocumentFragment.new(self, tags, self.root)
      end

      class << self
        ###
        # Parse HTML.  +thing+ may be a String, or any object that
        # responds to _read_ and _close_ such as an IO, or StringIO.
        # +url+ is resource where this document is located.  +encoding+ is the
        # encoding that should be used when processing the document. +options+
        # is a number that sets options in the parser, such as
        # Nokogiri::XML::ParseOptions::RECOVER.  See the constants in
        # Nokogiri::XML::ParseOptions.
        def parse string_or_io, url = nil, encoding = nil, options = XML::ParseOptions::DEFAULT_HTML, &block

          options = Nokogiri::XML::ParseOptions.new(options) if Fixnum === options
          # Give the options to the user
          yield options if block_given?

          if string_or_io.respond_to?(:encoding)
            unless string_or_io.encoding.name == "ASCII-8BIT"
              encoding ||= string_or_io.encoding.name
            end
          end

          if string_or_io.respond_to?(:read)
            url ||= string_or_io.respond_to?(:path) ? string_or_io.path : nil
            return read_io(string_or_io, url, encoding, options.to_i)
          end

          # read_memory pukes on empty docs
          return new if string_or_io.nil? or string_or_io.empty?

          read_memory(string_or_io, url, encoding, options.to_i)
        end
      end

    end
  end
end
