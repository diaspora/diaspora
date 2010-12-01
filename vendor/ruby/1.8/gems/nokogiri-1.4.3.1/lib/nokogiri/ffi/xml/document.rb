# :stopdoc:
module Nokogiri
  module XML
    class Document < Node

      attr_accessor :cstruct

      def url
        cstruct[:URL]
      end

      def root= new_root
        old_root = nil

        if new_root.nil?
          old_root_ptr = LibXML.xmlDocGetRootElement(cstruct)
          if (! old_root_ptr.null?)
            old_root = Node.wrap(old_root_ptr)
            LibXML.xmlUnlinkNode(old_root.cstruct)
            old_root.cstruct.keep_reference_from_document!
          end
          return new_root
        end

        if new_root.cstruct[:doc] != cstruct[:doc]
          old_root_ptr = LibXML.xmlDocGetRootElement(cstruct)
          new_root_ptr = LibXML.xmlDocCopyNode(new_root.cstruct, cstruct, 1)
          raise RuntimeError "Could not reparent node (xmlDocCopyNode)" if new_root_ptr.null?
          new_root = Node.wrap(new_root_ptr)
        end
        LibXML.xmlDocSetRootElement(cstruct, new_root.cstruct)
        if old_root_ptr && ! old_root_ptr.null?
          LibXML::XmlNode.new(old_root_ptr).keep_reference_from_document!
        end
        new_root
      end

      def root
        ptr = LibXML.xmlDocGetRootElement(cstruct)
        ptr.null? ? nil : Node.wrap(LibXML::XmlNode.new(ptr))
      end

      def encoding= encoding
        # TODO: if :encoding is already set, then it's probably getting leaked.
        cstruct[:encoding] = LibXML.xmlStrdup(encoding)
      end

      def encoding
        ptr = cstruct[:encoding]
        ptr.null? ? nil : ptr.read_string
      end

      def version
        cstruct[:version]
      end

      def self.read_io io, url, encoding, options
        wrap_with_error_handling do
          LibXML.xmlReadIO(IoCallbacks.reader(io), nil, nil, url, encoding, options)
        end
      end

      def self.read_memory(string, url, encoding, options)
        wrap_with_error_handling do
          LibXML.xmlReadMemory(string, string.length, url, encoding, options)
        end
      end

      def dup deep = 1
        dup_ptr = LibXML.xmlCopyDoc(cstruct, deep)
        return nil if dup_ptr.null?

        # xmlCopyDoc does not preserve document type. wtf?
        cstruct = LibXML::XmlDocumentCast.new(dup_ptr)
        cstruct[:type] = self.type

        self.class.wrap(dup_ptr)
      end

      def remove_namespaces!
        self.class.recursively_remove_namespaces_from_node(root)
      end

      def create_entity(name, entity_type=Nokogiri::XML::EntityDecl::INTERNAL_GENERAL,
                        external_id=nil, system_id=nil, content=nil)
        LibXML.xmlResetLastError()
        ptr = LibXML.xmlAddDocEntity(cstruct, name, entity_type, external_id, system_id, content)
        if ptr.null?
          error = LibXML.xmlGetLastError()
          if error
            raise SyntaxError.wrap(error)
          else
            raise RuntimeError, "Could not create entity"
          end
        end

        Node.wrap(LibXML::XmlEntity.new(ptr))
      end

      class << self
        def new(*args)
          version = args.first || "1.0"
          doc = wrap(LibXML.xmlNewDoc(version))
          doc.send :initialize, *args
          doc
        end

        def wrap doc_struct
          if doc_struct.is_a?(FFI::Pointer)
            # cast native pointers up into a doc cstruct
            return nil if doc_struct.null?
            doc_struct = LibXML::XmlDocument.new(doc_struct)
          end

          doc                  = self.allocate
          doc.cstruct          = doc_struct
          doc.cstruct.ruby_doc = doc
          doc.instance_eval { @decorators = nil; @node_cache = [] }
          doc.send :initialize
          doc
        end
      end

      private

      class << self
        def wrap_with_error_handling(&block)
          error_list = []
          LibXML.xmlInitParser()
          LibXML.xmlResetLastError()
          LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(error_list))

          ptr = yield

          LibXML.xmlSetStructuredErrorFunc(nil, nil)

          if ptr.null?
            error = LibXML.xmlGetLastError()
            if error
              raise SyntaxError.wrap(error)
            else
              raise RuntimeError, "Could not parse document"
            end
          end

          document = wrap(ptr)
          document.errors = error_list
          return document
        end

        def recursively_remove_namespaces_from_node(node)
          node.cstruct[:ns] = nil
          node.children.each do |child|
            recursively_remove_namespaces_from_node(child)
          end
          unless node.cstruct[:nsDef].nil?
            LibXML.xmlFreeNsList(node.cstruct[:nsDef])
            node.cstruct[:nsDef] = nil
          end
        end
      end

    end
  end
end
# :startdoc:
