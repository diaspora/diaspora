module Nokogiri
  module XML
    class Node
      # :stopdoc:

      attr_accessor :cstruct

      def pointer_id
        cstruct.pointer
      end

      def encode_special_chars(string)
        char_ptr = LibXML.xmlEncodeSpecialChars(self[:doc], string)
        encoded = char_ptr.read_string
        # TODO: encoding?
        LibXML.xmlFree(char_ptr)
        encoded
      end

      def internal_subset
        doc = cstruct.document
        dtd = LibXML.xmlGetIntSubset(doc)
        return nil if dtd.null?
        Node.wrap(dtd)
      end

      def external_subset
        doc = cstruct.document
        return nil if doc[:extSubset].null?

        Node.wrap(doc[:extSubset])
      end

      def create_internal_subset name, external_id, system_id
        raise("Document already has an internal subset") if internal_subset

        doc = cstruct.document
        dtd_ptr = LibXML.xmlCreateIntSubset doc, name, external_id, system_id

        return nil if dtd_ptr.null?

        Node.wrap dtd_ptr
      end

      def create_external_subset name, external_id, system_id
        raise("Document already has an external subset") if external_subset

        doc = cstruct.document
        dtd_ptr = LibXML.xmlNewDtd doc, name, external_id, system_id

        return nil if dtd_ptr.null?

        Node.wrap dtd_ptr
      end

      def dup(deep = 1)
        dup_ptr = LibXML.xmlDocCopyNode(cstruct, cstruct.document, deep)
        return nil if dup_ptr.null?
        Node.wrap(dup_ptr, self.class)
      end

      def unlink
        LibXML.xmlUnlinkNode(cstruct)
        cstruct.keep_reference_from_document!
        self
      end

      def blank?
        LibXML.xmlIsBlankNode(cstruct) == 1
      end

      def next_sibling
        cstruct_node_from :next
      end

      def previous_sibling
        cstruct_node_from :prev
      end

      def next_element
        LibXML.xmlNextElementSiblingHack self
      end

      def previous_element
        #
        #  note that we don't use xmlPreviousElementSibling here because it's buggy pre-2.7.7.
        #
        sibling_ptr = cstruct[:prev]

        while ! sibling_ptr.null?
          sibling_cstruct = LibXML::XmlNode.new(sibling_ptr)
          break if sibling_cstruct[:type] == ELEMENT_NODE
          sibling_ptr = sibling_cstruct[:prev]
        end

        return sibling_ptr.null? ? nil : Node.wrap(sibling_ptr)
      end

      def replace_node new_node
        Node.reparent_node_with(self, new_node) do |pivot_struct, reparentee_struct|
          retval = LibXML.xmlReplaceNode(pivot_struct, reparentee_struct)
          retval = reparentee_struct if retval == pivot_struct.pointer # for reparent_node_with semantics
          retval = LibXML::XmlNode.new(retval) if retval.is_a?(FFI::Pointer)
          if retval[:type] == TEXT_NODE
            if !retval[:prev].null? && LibXML::XmlNode.new(retval[:prev])[:type] == TEXT_NODE
              retval = LibXML::XmlNode.new(LibXML.xmlTextMerge(retval[:prev], retval))
            end
            if !retval[:next].null? && LibXML::XmlNode.new(retval[:next])[:type] == TEXT_NODE
              retval = LibXML::XmlNode.new(LibXML.xmlTextMerge(retval, retval[:next]))
            end
          end
          retval
        end
      end

      def children
        return NodeSet.new(nil) if cstruct[:children].null?
        child = Node.wrap(cstruct[:children])

        set = NodeSet.wrap(LibXML.xmlXPathNodeSetCreate(child.cstruct), self.document)
        return set unless child

        child_ptr = child.cstruct[:next]
        while ! child_ptr.null?
          child = Node.wrap(child_ptr)
          LibXML.xmlXPathNodeSetAddUnique(set.cstruct, child.cstruct)
          child_ptr = child.cstruct[:next]
        end

        return set
      end

      def element_children
        child = LibXML.xmlFirstElementChildHack(self)
        return NodeSet.new(nil) if child.nil?

        set = NodeSet.wrap(LibXML.xmlXPathNodeSetCreate(child.cstruct), self.document)
        return set unless child

        next_sibling = LibXML.xmlNextElementSiblingHack(child)
        while ! next_sibling.nil?
          child = next_sibling
          LibXML.xmlXPathNodeSetAddUnique(set.cstruct, child.cstruct)
          next_sibling = LibXML.xmlNextElementSiblingHack(child)
        end

        return set
      end

      def child
        (val = cstruct[:children]).null? ? nil : Node.wrap(val)
      end

      def first_element_child
        LibXML.xmlFirstElementChildHack(self)
      end

      def last_element_child
        LibXML.xmlLastElementChildHack(self)
      end

      def key?(attribute)
        ! (prop = LibXML.xmlHasProp(cstruct, attribute.to_s)).null?
      end

      def namespaced_key?(attribute, namespace)
        prop = LibXML.xmlHasNsProp(cstruct, attribute.to_s,
          namespace.nil? ? nil : namespace.to_s)
        !prop.null?
      end

      def []=(property, value)
        LibXML.xmlSetProp(cstruct, property, value)
        value
      end

      def get(attribute)
        return nil unless attribute
        propstr = LibXML.xmlGetProp(cstruct, attribute.to_s)
        return nil if propstr.null?
        rval = propstr.read_string # TODO: encoding?
        LibXML.xmlFree(propstr)
        rval
      end

      def set_namespace(namespace)
        LibXML.xmlSetNs(cstruct, namespace ? namespace.cstruct : nil)
        self
      end

      def attribute(name)
        attribute_nodes.find { |x| x.name == name }
      end

      def attribute_with_ns(name, namespace)
        prop = LibXML.xmlHasNsProp(cstruct, name.to_s,
          namespace.nil? ? NULL : namespace.to_s)
        return prop if prop.null?
        Node.wrap(prop)
      end

      def attribute_nodes
        Node.node_properties cstruct
      end

      def namespace
        cstruct[:ns].null? ? nil : Namespace.wrap(cstruct.document, cstruct[:ns])
      end

      def namespace_definitions
        list = []
        ns_ptr = cstruct[:nsDef]
        return list if ns_ptr.null?
        while ! ns_ptr.null?
          ns = Namespace.wrap(cstruct.document, ns_ptr)
          list << ns
          ns_ptr = ns.cstruct[:next]
        end
        list
      end

      def namespace_scopes
        ns_list = LibXML.xmlGetNsList(self.cstruct[:doc], self.cstruct)
        return [] if ns_list.null?

        list = []
        until (ns_ptr = ns_list.get_pointer(LibXML.pointer_offset(list.length))).null?
          list << Namespace.wrap(cstruct.document, ns_ptr)
        end

        LibXML.xmlFree(ns_list)
        list
      end

      def node_type
        cstruct[:type]
      end

      def native_content=(content)
        child_ptr = cstruct[:children]
        while ! child_ptr.null?
          child    = Node.wrap(child_ptr)
          next_ptr = child.cstruct[:next]
          LibXML.xmlUnlinkNode(child.cstruct)
          cstruct.keep_reference_from_document!
          child_ptr = next_ptr
        end
        LibXML.xmlNodeSetContent(cstruct, content)
        content
      end

      def content
        content_ptr = LibXML.xmlNodeGetContent(cstruct)
        return nil if content_ptr.null?
        content = content_ptr.read_string # TODO: encoding?
        LibXML.xmlFree(content_ptr)
        content
      end

      def add_child_node child
        Node.reparent_node_with(self, child) do |pivot_struct, reparentee_struct|
          LibXML.xmlAddChild(pivot_struct, reparentee_struct)
        end
      end

      def parent
        cstruct_node_from :parent
      end

      def node_name=(string)
        LibXML.xmlNodeSetName(cstruct, string)
        string
      end

      def node_name
        cstruct[:name] # TODO: encoding?
      end

      def path
        path_ptr = LibXML.xmlGetNodePath(cstruct)
        val = path_ptr.null? ? nil : path_ptr.read_string # TODO: encoding?
        LibXML.xmlFree(path_ptr)
        val
      end

      def add_next_sibling_node next_sibling
        Node.reparent_node_with(self, next_sibling) do |pivot_struct, reparentee_struct|
          LibXML.xmlAddNextSibling(pivot_struct, reparentee_struct)
        end
      end

      def add_previous_sibling_node prev_sibling
        Node.reparent_node_with(self, prev_sibling) do |pivot_struct, reparentee_struct|
          LibXML.xmlAddPrevSibling(pivot_struct, reparentee_struct)
        end
      end

      def native_write_to(io, encoding, indent_string, options)
        set_xml_indent_tree_output 1
        set_xml_tree_indent_string indent_string
        savectx = LibXML.xmlSaveToIO(IoCallbacks.writer(io), nil, nil, encoding, options)
        LibXML.xmlSaveTree(savectx, cstruct)
        LibXML.xmlSaveClose(savectx)
        io
      end

      def line
        cstruct[:line]
      end

      def add_namespace_definition(prefix, href)
        ns = LibXML.xmlSearchNs(cstruct.document, cstruct, prefix.nil? ? nil : prefix.to_s)
        namespacee = self
        if ns.null?
          namespacee = parent if type != ELEMENT_NODE
          ns = LibXML.xmlNewNs(namespacee.cstruct, href, prefix)
        end
        return nil if ns.null?
        LibXML.xmlSetNs(cstruct, ns) if (prefix.nil? || self != namespacee)
        Namespace.wrap(cstruct.document, ns)
      end

      def self.new(name, doc, *rest)
        ptr = LibXML.xmlNewNode(nil, name.to_s)

        node_cstruct = LibXML::XmlNode.new(ptr)
        node_cstruct[:doc] = doc.cstruct[:doc]
        node_cstruct.keep_reference_from_document!

        node = Node.wrap(
          node_cstruct,
          Node == self ? nil : self
        )
        node.send :initialize, name, doc, *rest
        yield node if block_given?
        node
      end

      def dump_html
        return to_xml if type == DOCUMENT_NODE
        buffer = LibXML::XmlBuffer.new(LibXML.xmlBufferCreate())
        LibXML.htmlNodeDump(buffer, cstruct[:doc], cstruct)
        buffer[:content] # TODO: encoding?
      end

      def compare(other)
        LibXML.xmlXPathCmpNodes(other.cstruct, self.cstruct)
      end

      def self.wrap(node_struct, klass=nil)
        if node_struct.is_a?(FFI::Pointer)
          # cast native pointers up into a node cstruct
          return nil if node_struct.null?
          node_struct = LibXML::XmlNode.new(node_struct)
        end

        raise "wrapping a node without a document" unless node_struct.document

        document_struct = node_struct.document
        document_obj = document_struct.nil? ? nil : document_struct.ruby_doc
        if node_struct[:type] == DOCUMENT_NODE || node_struct[:type] == HTML_DOCUMENT_NODE
          return document_obj
        end

        ruby_node = node_struct.ruby_node
        return ruby_node unless ruby_node.nil?

        klasses = case node_struct[:type]
                  when ELEMENT_NODE then [XML::Element]
                  when TEXT_NODE then [XML::Text]
                  when ENTITY_REF_NODE then [XML::EntityReference]
                  when ATTRIBUTE_DECL then [XML::AttributeDecl, LibXML::XmlAttribute]
                  when ELEMENT_DECL then [XML::ElementDecl, LibXML::XmlElement]
                  when COMMENT_NODE then [XML::Comment]
                  when DOCUMENT_FRAG_NODE then [XML::DocumentFragment]
                  when PI_NODE then [XML::ProcessingInstruction]
                  when ATTRIBUTE_NODE then [XML::Attr]
                  when ENTITY_DECL then [XML::EntityDecl, LibXML::XmlEntity]
                  when CDATA_SECTION_NODE then [XML::CDATA]
                  when DTD_NODE then [XML::DTD, LibXML::XmlDtd]
                  else [XML::Node]
                  end

        if klass
          node = klass.allocate
        else
          node = klasses.first.allocate
        end
        node.cstruct = klasses[1] ? klasses[1].new(node_struct.pointer) : node_struct

        node.cstruct.ruby_node = node

        if document_obj
          node.instance_variable_set(:@document, document_obj)
          cache = document_obj.instance_variable_get(:@node_cache)
          cache << node
          document_obj.decorate(node)
        end

        node
      end

      def document
        cstruct.document.ruby_doc
      end

      def in_context(string, options)
        raise RuntimeError, "no contextual parsing on unlinked nodes" if parent.nil?

        @errors = []
        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(@errors))
        LibXML.htmlHandleOmittedElem(0)

        list_memory = FFI::MemoryPointer.new :pointer
        LibXML.xmlParseInNodeContext(cstruct, string, string.length, options, list_memory)

        LibXML.htmlHandleOmittedElem(1)
        LibXML.xmlSetStructuredErrorFunc(nil, nil)

        set = NodeSet.wrap(LibXML.xmlXPathNodeSetCreate(nil), document)
        list_ptr = list_memory.get_pointer(0)
        while ! list_ptr.null?
          list = Node.wrap(list_ptr)
          LibXML.xmlXPathNodeSetAddUnique(set.cstruct, list.cstruct)
          list_ptr = list.cstruct[:next]
        end
        set
      end

      class << self
        def node_properties(cstruct)
          attr = []
          prop_cstruct = cstruct[:properties]
          while ! prop_cstruct.null?
            prop = Node.wrap(prop_cstruct)
            attr << prop
            prop_cstruct = prop.cstruct[:next]
          end
          attr
        end
      end

      private

      def self.reparent_node_with(pivot, reparentee, &block)
        raise(ArgumentError, "node must be a Nokogiri::XML::Node") unless reparentee.is_a?(Nokogiri::XML::Node)
        raise(ArgumentError, "cannot reparent a document node") if reparentee.node_type == DOCUMENT_NODE || reparentee.node_type == HTML_DOCUMENT_NODE

        pivot_struct = pivot.cstruct
        reparentee_struct = reparentee.cstruct

        LibXML.xmlUnlinkNode(reparentee_struct)

        if reparentee_struct[:doc] != pivot_struct[:doc] || reparentee_struct[:type] == TEXT_NODE
          reparentee_struct.keep_reference_from_document!
          reparentee_struct = LibXML.xmlDocCopyNode(reparentee_struct, pivot_struct.document, 1)
          raise(RuntimeError, "Could not reparent node (xmlDocCopyNode)") unless reparentee_struct
          reparentee_struct = LibXML::XmlNode.new(reparentee_struct)
        end

        if reparentee_struct[:type] == TEXT_NODE && !pivot_struct[:next].null?
          next_text = Node.wrap(pivot_struct[:next])
          if next_text.cstruct[:type] == TEXT_NODE
            new_next_text = LibXML.xmlDocCopyNode(next_text.cstruct, pivot_struct[:doc], 1)
            LibXML.xmlUnlinkNode(next_text.cstruct)
            next_text.cstruct.keep_reference_from_document!
            LibXML.xmlAddNextSibling(pivot_struct, new_next_text);
          end
        end

        if reparentee_struct[:type] == TEXT_NODE && pivot_struct[:type] == TEXT_NODE && Nokogiri.is_2_6_16?
          pivot_struct.pointer.put_pointer(pivot_struct.offset_of(:content), LibXML.xmlStrdup(pivot_struct[:content]))
        end

        reparented_struct = block.call(pivot_struct, reparentee_struct)
        raise(RuntimeError, "Could not reparent node") unless reparented_struct

        reparented_struct = LibXML::XmlNode.new(reparented_struct) if reparented_struct.is_a?(FFI::Pointer)
        reparentee.cstruct = reparented_struct

        relink_namespace reparented_struct

        reparented = Node.wrap(reparented_struct)
        reparented.decorate!
        reparented
      end

      def self.relink_namespace(reparented_struct)
        return if reparented_struct[:parent].null?

        # Make sure that our reparented node has the correct namespaces
        if reparented_struct[:ns].null? && reparented_struct[:doc] != reparented_struct[:parent]
          LibXML.xmlSetNs(reparented_struct, LibXML::XmlNode.new(reparented_struct[:parent])[:ns])
        end

        # Search our parents for an existing definition
        if ! reparented_struct[:nsDef].null?
          curr = reparented_struct[:nsDef]
          prev = nil

          while (! curr.null?)
            curr_ns = LibXML::XmlNs.new(curr)
            ns = LibXML.xmlSearchNsByHref(
              reparented_struct[:doc],
              reparented_struct[:parent],
              curr_ns[:href]
              )
            # If we find the namespace is already declared, remove it from this
            # definition list.
            if (! ns.null? && ns != curr)
              if prev
                prev[:next] = curr_ns[:next]
              else
                reparented_struct[:nsDef] = curr_ns[:next]
              end
              curr_ns.keep_reference_from!(reparented_struct.document)
            else
              prev = curr_ns
            end
            curr = curr_ns[:next]
          end
        end

        # Only walk all children if there actually is a namespace we need to reparent.
        return if reparented_struct[:ns].null?

        # When a node gets reparented, walk it's children to make sure that
        # their namespaces are reparented as well.
        child_ptr = reparented_struct[:children]
        while ! child_ptr.null?
          child_struct = LibXML::XmlNode.new(child_ptr)
          relink_namespace child_struct
          child_ptr = child_struct[:next]
        end
      end

      def cstruct_node_from(sym)
        (val = cstruct[sym]).null? ? nil : Node.wrap(val)
      end

      def set_xml_indent_tree_output(value)
        LibXML.__xmlIndentTreeOutput.write_int(value)
      end

      def set_xml_tree_indent_string(value)
        LibXML.__xmlTreeIndentString.write_pointer(LibXML.xmlStrdup(value.to_s))
      end

      # :startdoc:
    end
  end
end
class Nokogiri::XML::Element < Nokogiri::XML::Node; end
class Nokogiri::XML::CharacterData < Nokogiri::XML::Node; end
