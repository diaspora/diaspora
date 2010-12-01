require "helper"

module Nokogiri
  module XML
    class TestNodeAttributes < Nokogiri::TestCase
      def test_attribute_with_ns
        doc = Nokogiri::XML <<-eoxml
          <root xmlns:tlm='http://tenderlovemaking.com/'>
            <node tlm:foo='bar' foo='baz' />
          </root>
        eoxml

        node = doc.at('node')

        assert_equal 'bar',
          node.attribute_with_ns('foo', 'http://tenderlovemaking.com/').value
      end

      def test_namespace_key?
        doc = Nokogiri::XML <<-eoxml
          <root xmlns:tlm='http://tenderlovemaking.com/'>
            <node tlm:foo='bar' foo='baz' />
          </root>
        eoxml

        node = doc.at('node')

        assert node.namespaced_key?('foo', 'http://tenderlovemaking.com/')
        assert node.namespaced_key?('foo', nil)
        assert !node.namespaced_key?('foo', 'foo')
      end
    end
  end
end
