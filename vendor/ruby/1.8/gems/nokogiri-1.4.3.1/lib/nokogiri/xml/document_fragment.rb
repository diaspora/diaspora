module Nokogiri
  module XML
    class DocumentFragment < Nokogiri::XML::Node
      ##
      #  Create a new DocumentFragment from +tags+.
      #
      #  If +ctx+ is present, it is used as a context node for the
      #  subtree created, e.g., namespaces will be resolved relative
      #  to +ctx+.
      def initialize document, tags = nil, ctx = nil
        return self unless tags

        children = if ctx
                     ctx.parse(tags.strip)
                   else
                     XML::Document.parse("<root>#{tags.strip}</root>") \
                       .xpath("/root/node()")
                   end
        children.each { |child| child.parent = self }
      end

      ###
      # return the name for DocumentFragment
      def name
        '#document-fragment'
      end

      ###
      # Convert this DocumentFragment to a string
      def to_s
        children.to_s
      end

      ###
      # Convert this DocumentFragment to html
      # See Nokogiri::XML::NodeSet#to_html
      def to_html *args
        children.to_html(*args)
      end

      ###
      # Convert this DocumentFragment to xhtml
      # See Nokogiri::XML::NodeSet#to_xhtml
      def to_xhtml *args
        children.to_xhtml(*args)
      end

      ###
      # Convert this DocumentFragment to xml
      # See Nokogiri::XML::NodeSet#to_xml
      def to_xml *args
        children.to_xml(*args)
      end

      ###
      # Search this fragment.  See Nokogiri::XML::Node#css
      def css *args
        if children.any?
          children.css(*args)
        else
          NodeSet.new(document)
        end
      end

      alias :serialize :to_s

      class << self
        ####
        # Create a Nokogiri::XML::DocumentFragment from +tags+
        def parse tags
          self.new(XML::Document.new, tags)
        end
      end

      private

      def coerce data
        return super unless String === data

        document.fragment(data).children
      end
    end
  end
end
