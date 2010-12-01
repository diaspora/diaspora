require "helper"

class TestMemoryLeak < Nokogiri::TestCase

  if ENV['NOKOGIRI_GC'] # turning these off by default for now

    def test_dont_hurt_em_why
      content = File.open("#{File.dirname(__FILE__)}/files/dont_hurt_em_why.xml").read
      ndoc = Nokogiri::XML(content)
      2.times do
        ndoc.search('status text').first.inner_text
        ndoc.search('user name').first.inner_text
        GC.start
      end
    end

    def test_for_memory_leak
      begin
        #  we don't use Dike in any tests, but requiring it has side effects
        #  that can create memory leaks, and that's what we're testing for.
        require 'rubygems'
        require 'dike' # do not remove!

        count_start = count_object_space_documents
        xml_data = <<-EOS
        <test>
          <items>
            <item>abc</item>
            <item>1234</item>
            <item>Zzz</item>
          <items>
        </test>
        EOS
        20.times do
          doc = Nokogiri::XML(xml_data)
          doc.xpath("//item")
        end
        2.times { GC.start }
        count_end = count_object_space_documents
        assert((count_end - count_start) <= 2, "memory leak detected")
      rescue LoadError
        puts "\ndike is not installed, skipping memory leak test"
      end
    end

    if Nokogiri.ffi?
      [ ['Node', 'p', nil],
        ['CDATA', nil, 'content'],
        ['Comment', nil, 'content'],
        ['DocumentFragment', nil],
        ['EntityReference', nil, 'p'],
        ['ProcessingInstruction', nil, 'p', 'content'] ].each do |klass, *args|

        define_method "test_for_leaked_#{klass}_nodes" do
          Nokogiri::LibXML.expects(:xmlAddChild).at_least(1) # more than once shows we're GCing properly
          10.times {
            xml = Nokogiri::XML("<root></root>")
            2.times { Nokogiri::XML.const_get(klass).new(*(args.collect{|arg| arg || xml})) }
            GC.start
          }
          GC.start
        end

      end

      def test_for_leaked_attr_nodes
        Nokogiri::LibXML.expects(:xmlFreePropList).at_least(1) # more than once shows we're GCing properly
        10.times {
          xml = Nokogiri::XML("<root></root>")
          2.times { Nokogiri::XML::Attr.new(xml, "p") }
          GC.start
        }
        GC.start
      end

    end # if ffi

  end # if NOKOGIRI_GC

  private

  def count_object_space_documents
    count = 0
    ObjectSpace.each_object {|j| count += 1 if j.is_a?(Nokogiri::XML::Document) }
    count
  end
end
