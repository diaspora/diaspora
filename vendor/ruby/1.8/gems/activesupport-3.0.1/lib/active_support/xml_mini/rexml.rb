require 'active_support/core_ext/kernel/reporting'
require 'active_support/core_ext/object/blank'

# = XmlMini ReXML implementation
module ActiveSupport
  module XmlMini_REXML #:nodoc:
    extend self

    CONTENT_KEY = '__content__'.freeze

    # Parse an XML Document string or IO into a simple hash
    #
    # Same as XmlSimple::xml_in but doesn't shoot itself in the foot,
    # and uses the defaults from Active Support.
    #
    # data::
    #   XML Document string or IO to parse
    def parse(data)
      if !data.respond_to?(:read)
        data = StringIO.new(data || '')
      end

      char = data.getc
      if char.nil?
        {}
      else
        data.ungetc(char)
        silence_warnings { require 'rexml/document' } unless defined?(REXML::Document)
        doc = REXML::Document.new(data)

        if doc.root
          merge_element!({}, doc.root)
        else
          raise REXML::ParseException,
            "The document #{doc.to_s.inspect} does not have a valid root"
        end
      end
    end

    private
      # Convert an XML element and merge into the hash
      #
      # hash::
      #   Hash to merge the converted element into.
      # element::
      #   XML element to merge into hash
      def merge_element!(hash, element)
        merge!(hash, element.name, collapse(element))
      end

      # Actually converts an XML document element into a data structure.
      #
      # element::
      #   The document element to be collapsed.
      def collapse(element)
        hash = get_attributes(element)

        if element.has_elements?
          element.each_element {|child| merge_element!(hash, child) }
          merge_texts!(hash, element) unless empty_content?(element)
          hash
        else
          merge_texts!(hash, element)
        end
      end

      # Merge all the texts of an element into the hash
      #
      # hash::
      #   Hash to add the converted element to.
      # element::
      #   XML element whose texts are to me merged into the hash
      def merge_texts!(hash, element)
        unless element.has_text?
          hash
        else
          # must use value to prevent double-escaping
          texts = ''
          element.texts.each { |t| texts << t.value }
          merge!(hash, CONTENT_KEY, texts)
        end
      end

      # Adds a new key/value pair to an existing Hash. If the key to be added
      # already exists and the existing value associated with key is not
      # an Array, it will be wrapped in an Array. Then the new value is
      # appended to that Array.
      #
      # hash::
      #   Hash to add key/value pair to.
      # key::
      #   Key to be added.
      # value::
      #   Value to be associated with key.
      def merge!(hash, key, value)
        if hash.has_key?(key)
          if hash[key].instance_of?(Array)
            hash[key] << value
          else
            hash[key] = [hash[key], value]
          end
        elsif value.instance_of?(Array)
          hash[key] = [value]
        else
          hash[key] = value
        end
        hash
      end

      # Converts the attributes array of an XML element into a hash.
      # Returns an empty Hash if node has no attributes.
      #
      # element::
      #   XML element to extract attributes from.
      def get_attributes(element)
        attributes = {}
        element.attributes.each { |n,v| attributes[n] = v }
        attributes
      end

      # Determines if a document element has text content
      #
      # element::
      #   XML element to be checked.
      def empty_content?(element)
        element.texts.join.blank?
      end
  end
end
