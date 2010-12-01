require "helper"

if defined?(Nokogiri::LibXML)

  class FFI::TestDocument < Nokogiri::TestCase

    def test_ruby_doc_reflection
      doc = Nokogiri::XML("<root><foo>foo</foo></root>")
      assert_equal doc, doc.cstruct.ruby_doc
    end

    def test_ruby_doc_setter
      doc = Nokogiri::XML("<root><foo>foo</foo></root>")
      foo = "foobar"
      doc.cstruct.ruby_doc = foo
      assert_equal foo, doc.cstruct.ruby_doc
    end

    def test_unlinked_nodes
      doc = Nokogiri::XML("<root><foo>foo</foo></root>")
      assert_instance_of Nokogiri::LibXML::XmlNodeSetCast, doc.cstruct.unlinked_nodes
    end

    def test_unlinked_nodes_contains_unlinked_nodes
      doc = Nokogiri::XML("<root><foo>foo</foo></root>")
      node = doc.xpath('//foo').first
      assert_equal 0, doc.cstruct.unlinked_nodes[:nodeNr]
      node.unlink
      assert_equal 1, doc.cstruct.unlinked_nodes[:nodeNr]
      assert_equal node.cstruct.pointer, doc.cstruct.unlinked_nodes[:nodeTab].get_pointer(0)
    end

  end

end
