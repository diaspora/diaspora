# :stopdoc:
module Nokogiri
  module XML
    class SyntaxError < ::Nokogiri::SyntaxError

      attr_accessor :cstruct

      def initialize(message)
        self.cstruct = LibXML::XmlSyntaxError.new(LibXML::XmlSyntaxError.allocate())
        self.cstruct[:message] = LibXML.xmlStrdup(message)
      end

      def domain
        cstruct[:domain]
      end

      def code
        cstruct[:code]
      end

      def message
        val = cstruct[:message]
        val.null? ? nil : val.read_string.chomp
      end
      undef_method :inspect
      alias_method :inspect, :message
      undef_method :to_s
      alias_method :to_s, :message

      def message=(string)
        unless cstruct[:message].null?
          LibXML.xmlFree(cstruct[:message])
        end
        cstruct[:message] = LibXML.xmlStrdup(string)
        string
      end

      def initialize_copy(other)
        raise ArgumentError, "node must be a Nokogiri::XML::SyntaxError" unless other.is_a?(Nokogiri::XML::SyntaxError)
        LibXML.xmlCopyError(other.cstruct, cstruct)
        self
      end

      def level
        cstruct[:level]
      end

      def file
        cstruct[:file].null? ? nil : cstruct[:file]
      end

      def line
        cstruct[:line]
      end

      def str1
        cstruct[:str1]
      end

      def str2
        cstruct[:str]
      end

      def str3
        cstruct[:str3]
      end

      def int1
        cstruct[:int1]
      end

      def column
        cstruct[:int2]
      end
      alias_method :int2, :column

      class << self
        def error_array_pusher(array)
          Proc.new do |_ignored_, error|
            array << wrap(error) if array
          end
        end

        def wrap(error_ptr)
          error_struct = LibXML::XmlSyntaxError.allocate
          LibXML.xmlCopyError(error_ptr, error_struct)
          error_cstruct = LibXML::XmlSyntaxError.new(error_struct)
          error = self.allocate # will generate XML::XPath::SyntaxError or XML::SyntaxError
          error.cstruct = error_cstruct
          error
        end
      end

    end
  end

end
# :startdoc:
