module Nokogiri
  module XML
    ##
    # Nokogiri::XML::Document is the main entry point for dealing with
    # XML documents.  The Document is created by parsing an XML document.
    # See Nokogiri.XML()
    #
    # For searching a Document, see Nokogiri::XML::Node#css and
    # Nokogiri::XML::Node#xpath
    class Document < Nokogiri::XML::Node
      ##
      # Parse an XML file.  +thing+ may be a String, or any object that
      # responds to _read_ and _close_ such as an IO, or StringIO.
      # +url+ is resource where this document is located.  +encoding+ is the
      # encoding that should be used when processing the document. +options+
      # is a number that sets options in the parser, such as
      # Nokogiri::XML::ParseOptions::RECOVER.  See the constants in
      # Nokogiri::XML::ParseOptions.
      def self.parse string_or_io, url = nil, encoding = nil, options = ParseOptions::DEFAULT_XML, &block

        options = Nokogiri::XML::ParseOptions.new(options) if Fixnum === options
        # Give the options to the user
        yield options if block_given?

        if string_or_io.respond_to?(:read)
          url ||= string_or_io.respond_to?(:path) ? string_or_io.path : nil
          return read_io(string_or_io, url, encoding, options.to_i)
        end

        # read_memory pukes on empty docs
        return new if string_or_io.nil? or string_or_io.empty?

        read_memory(string_or_io, url, encoding, options.to_i)
      end

      # A list of Nokogiri::XML::SyntaxError found when parsing a document
      attr_accessor :errors

      def initialize *args # :nodoc:
        @errors     = []
        @decorators = nil
      end

      ##
      # Create an element with +name+, and optionally setting the content and attributes.
      #
      #   doc.create_element "div" # <div></div>
      #   doc.create_element "div", :class => "container" # <div class='container'></div>
      #   doc.create_element "div", "contents" # <div>contents</div>
      #   doc.create_element "div", "contents", :class => "container" # <div class='container'>contents</div>
      #   doc.create_element "div" { |node| node['class'] = "container" } # <div class='container'></div>
      #
      def create_element name, *args, &block
        elm = Nokogiri::XML::Element.new(name, self, &block)
        args.each do |arg|
          case arg
          when Hash
            arg.each { |k,v|
              key = k.to_s
              if key =~ /^xmlns(:\w+)?$/
                ns_name = key.split(":", 2)[1]
                elm.add_namespace_definition ns_name, v
                next
              end
              elm[k.to_s] = v.to_s
            }
          else
            elm.content = arg
          end
        end
        elm
      end

      # Create a text node with +text+
      def create_text_node text, &block
        Nokogiri::XML::Text.new(text.to_s, self, &block)
      end

      # Create a CDATA element containing +text+
      def create_cdata text
        Nokogiri::XML::CDATA.new(self, text.to_s)
      end

      # The name of this document.  Always returns "document"
      def name
        'document'
      end

      # A reference to +self+
      def document
        self
      end

      ##
      # Recursively get all namespaces from this node and its subtree and
      # return them as a hash.
      #
      # For example, given this document:
      #
      #   <root xmlns:foo="bar">
      #     <bar xmlns:hello="world" />
      #   </root>
      #
      # This method will return:
      #
      #   { 'xmlns:foo' => 'bar', 'xmlns:hello' => 'world' }
      #
      # WARNING: this method will clobber duplicate names in the keys.
      # For example, given this document:
      #
      #   <root xmlns:foo="bar">
      #     <bar xmlns:foo="baz" />
      #   </root>
      #
      # The hash returned will look like this: { 'xmlns:foo' => 'bar' }
      def collect_namespaces
        ns = {}
        traverse { |j| ns.merge!(j.namespaces) }
        ns
      end

      # Get the list of decorators given +key+
      def decorators key
        @decorators ||= Hash.new
        @decorators[key] ||= []
      end

      ##
      # Validate this Document against it's DTD.  Returns a list of errors on
      # the document or +nil+ when there is no DTD.
      def validate
        return nil unless internal_subset
        internal_subset.validate self
      end

      ##
      # Explore a document with shortcut methods.
      def slop!
        unless decorators(XML::Node).include? Nokogiri::Decorators::Slop
          decorators(XML::Node) << Nokogiri::Decorators::Slop
          decorate!
        end

        self
      end

      ##
      # Apply any decorators to +node+
      def decorate node
        return unless @decorators
        @decorators.each { |klass,list|
          next unless node.is_a?(klass)
          list.each { |moodule| node.extend(moodule) }
        }
      end

      alias :to_xml :serialize
      alias :clone :dup

      # Get the hash of namespaces on the root Nokogiri::XML::Node
      def namespaces
        root ? root.namespaces : {}
      end

      ##
      # Create a Nokogiri::XML::DocumentFragment from +tags+
      # Returns an empty fragment if +tags+ is nil.
      def fragment tags = nil
        DocumentFragment.new(self, tags, self.root)
      end

      undef_method :swap, :parent, :namespace, :default_namespace=
      undef_method :add_namespace_definition, :attributes
      undef_method :namespace_definitions, :line, :add_namespace

      def add_child child
        raise "Document already has a root node" if root
        if child.type == Node::DOCUMENT_FRAG_NODE
          raise "Document cannot have multiple root nodes" if child.children.size > 1
          super(child.children.first)
        else
          super
        end
      end
      alias :<< :add_child

      private
      def inspect_attributes
        [:name, :children]
      end
    end
  end
end
