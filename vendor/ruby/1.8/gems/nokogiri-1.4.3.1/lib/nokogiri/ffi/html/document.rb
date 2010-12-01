module Nokogiri
  module HTML
    class Document < XML::Document

      attr_accessor :cstruct # :nodoc:

      def self.new(*args) # :nodoc:
        uri         = args[0]
        external_id = args[1]
        doc = wrap(LibXML.htmlNewDoc(uri, external_id))
        doc.send :initialize, *args
        doc
      end

      def self.read_io(io, url, encoding, options) # :nodoc:
        wrap_with_error_handling do
          LibXML.htmlReadIO(IoCallbacks.reader(io), nil, nil, url, encoding, options)
        end
      end

      def self.read_memory(string, url, encoding, options) # :nodoc:
        wrap_with_error_handling do
          LibXML.htmlReadMemory(string, string.length, url, encoding, options)
        end
      end
    end
  end
end
