module Nokogiri
  module XML
    class NodeSet

      attr_accessor :cstruct # :nodoc:

      def dup # :nodoc:
        dup = LibXML.xmlXPathNodeSetMerge(nil, self.cstruct)
        NodeSet.wrap(dup, self.document)
      end

      def length # :nodoc:
        cstruct.pointer.null? ? 0 : cstruct[:nodeNr]
      end

      def push(node) # :nodoc:
        raise(ArgumentError, "node must be a Nokogiri::XML::Node") unless node.is_a?(XML::Node) || node.is_a?(XML::Namespace)
        LibXML.xmlXPathNodeSetAdd(cstruct, node.cstruct)
        self
      end

      def |(node_set) # :nodoc:
        raise(ArgumentError, "node_set must be a Nokogiri::XML::NodeSet") unless node_set.is_a?(XML::NodeSet)
        new_set_ptr = LibXML::xmlXPathNodeSetMerge(nil, self.cstruct)
        new_set_ptr = LibXML::xmlXPathNodeSetMerge(new_set_ptr, node_set.cstruct)

        NodeSet.wrap(new_set_ptr, self.document)
      end

      def -(node_set) # :nodoc:
        raise(ArgumentError, "node_set must be a Nokogiri::XML::NodeSet") unless node_set.is_a?(XML::NodeSet)
        new_set_ptr = LibXML.xmlXPathNodeSetMerge(nil, self.cstruct)

        other_nodetab = node_set.cstruct.nodeTab
        node_set.cstruct[:nodeNr].times do |j|
          LibXML.xmlXPathNodeSetDel(new_set_ptr, other_nodetab[j])
        end        
        NodeSet.wrap(new_set_ptr, self.document)
      end

      def delete(node) # :nodoc:
        raise(ArgumentError, "node must be a Nokogiri::XML::Node") unless node.is_a?(XML::Node) || node.is_a?(XML::Namespace)
        if LibXML.xmlXPathNodeSetContains(cstruct, node.cstruct) != 0
          LibXML.xmlXPathNodeSetDel(cstruct, node.cstruct)
          return node
        end
        return nil
      end

      def [](*args) # :nodoc:
        raise(ArgumentError, "got #{args.length} arguments, expected 1 (or 2)") if args.length > 2

        if args.length == 2
          beg = args[0]
          len = args[1]
          beg += cstruct[:nodeNr] if beg < 0
          return subseq(beg, len)
        end
        arg = args[0]

        return subseq(arg.first, arg.last-arg.first+1) if arg.is_a?(Range)

        index_at(arg)
      end
      alias_method :slice, :[]

      def &(node_set) # :nodoc:
        raise(ArgumentError, "node_set must be a Nokogiri::XML::NodeSet") unless node_set.is_a?(XML::NodeSet)
        new_set_ptr = LibXML.xmlXPathIntersection(cstruct, node_set.cstruct)
        NodeSet.wrap(new_set_ptr, self.document)
      end

      def include?(node) # :nodoc:
        raise(ArgumentError, "node must be a Nokogiri::XML::Node") unless node.is_a?(XML::Node) || node.is_a?(XML::Namespace)
        (LibXML.xmlXPathNodeSetContains(cstruct, node.cstruct) != 0) ? true : false
      end

      def to_a # :nodoc:
        cstruct.nodeTab.collect do |node|
          node_cstruct = LibXML::XmlNode.new(node)
          if node_cstruct[:type] == XML::Node::NAMESPACE_DECL
            Namespace.wrap(document.cstruct, node)
          else
            Node.wrap(node_cstruct)
          end
        end
      end

      def unlink # :nodoc:
        nodetab = cstruct.nodeTab
        cstruct[:nodeNr].times do |j|
          node_cstruct = LibXML::XmlNode.new(nodetab[j])
          if node_cstruct[:type] != XML::Node::NAMESPACE_DECL
            node = Node.wrap(node_cstruct)
            node.unlink
            nodetab[j] = node.cstruct.pointer
          end
        end
        cstruct.nodeTab = nodetab
        self
      end

      def self.new document, list = [] # :nodoc:
        set = NodeSet.wrap(LibXML.xmlXPathNodeSetCreate(nil), document)
        set.document = document
        list.each { |x| set << x }
        yield set if block_given?
        set
      end

      def self.wrap(ptr, document) # :nodoc:
        set = allocate
        set.cstruct = LibXML::XmlNodeSet.new(ptr)
        if document
          set.document = document
          document.decorate(set)
        end
        set
      end

      private

      def index_at(number) # :nodoc:
        return nil if (number >= cstruct[:nodeNr] || number.abs > cstruct[:nodeNr])
        number = number + cstruct[:nodeNr] if number < 0
        node_ptr = cstruct.nodeAt(number)
        node_cstruct = LibXML::XmlNode.new(node_ptr)
        if node_cstruct[:type] == XML::Node::NAMESPACE_DECL
          Namespace.wrap(document.cstruct, node_ptr)
        else
          Node.wrap(node_cstruct)
        end
      end

      def subseq(beg, len) # :nodoc:
        return nil if beg > cstruct[:nodeNr]
        return nil if beg < 0 || len < 0
        len = cstruct[:nodeNr] - beg if beg + len > cstruct[:nodeNr]

        set = NodeSet.wrap(LibXML.xmlXPathNodeSetCreate(nil), self.document)
        beg.upto(beg+len-1) do |j|
          LibXML.xmlXPathNodeSetAddUnique(set.cstruct, cstruct.nodeAt(j));
        end
        set
      end

    end
  end
end
