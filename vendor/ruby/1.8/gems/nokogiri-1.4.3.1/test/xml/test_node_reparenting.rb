require "helper"

module Nokogiri
  module XML
    class TestNodeReparenting < Nokogiri::TestCase

      describe "standard node reparenting behavior" do
        # describe "namespace handling during reparenting" do
        #   describe "given a Node" do
        #     describe "with a Namespace" do
        #       it "keeps the Namespace"
        #     end
        #     describe "given a parent Node with a default and a non-default Namespace" do
        #       describe "passed an Node without a namespace" do
        #         it "inserts an Node that inherits the default Namespace"
        #       end
        #       describe "passed a Node with a Namespace that matches the parent's non-default Namespace" do
        #         it "inserts a Node that inherits the matching parent Namespace"
        #       end
        #     end
        #   end
        #   describe "given a markup string" do
        #     describe "parsed relative to the document" do
        #       describe "with a Namespace" do
        #         it "keeps the Namespace"
        #       end
        #       describe "given a parent Node with a default and a non-default Namespace" do
        #         describe "passed an Node without a namespace" do
        #           it "inserts an Node that inherits the default Namespace"
        #         end
        #         describe "passed a Node with a Namespace that matches the parent's non-default Namespace" do
        #           it "inserts a Node that inherits the matching parent Namespace"
        #         end
        #       end
        #     end
        #     describe "parsed relative to a specific node" do
        #       describe "with a Namespace" do
        #         it "keeps the Namespace"
        #       end
        #       describe "given a parent Node with a default and a non-default Namespace" do
        #         describe "passed an Node without a namespace" do
        #           it "inserts an Node that inherits the default Namespace"
        #         end
        #         describe "passed a Node with a Namespace that matches the parent's non-default Namespace" do
        #           it "inserts a Node that inherits the matching parent Namespace"
        #         end
        #       end
        #     end
        #   end
        # end

        {
          :add_child            => {:target => "/root/a1",        :returns => :reparented, :children_tags => %w[text b1 b2]},
          :<<                   => {:target => "/root/a1",        :returns => :reparented, :children_tags => %w[text b1 b2]},

          :replace              => {:target => "/root/a1/node()", :returns => :reparented, :children_tags => %w[b1 b2]},
          :swap                 => {:target => "/root/a1/node()", :returns => :self,       :children_tags => %w[b1 b2]},

          :inner_html=          => {:target => "/root/a1",        :returns => :self,       :children_tags => %w[b1 b2]},

          :add_previous_sibling => {:target => "/root/a1/text()", :returns => :reparented, :children_tags => %w[b1 b2 text]},
          :previous=            => {:target => "/root/a1/text()", :returns => :reparented, :children_tags => %w[b1 b2 text]},
          :before               => {:target => "/root/a1/text()", :returns => :self,       :children_tags => %w[b1 b2 text]},

          :add_next_sibling     => {:target => "/root/a1/text()", :returns => :reparented, :children_tags => %w[text b1 b2]},
          :next=                => {:target => "/root/a1/text()", :returns => :reparented, :children_tags => %w[text b1 b2]},
          :after                => {:target => "/root/a1/text()", :returns => :self,       :children_tags => %w[text b1 b2]}
        }.each do |method, params|

          before do
            @doc  = Nokogiri::XML "<root><a1>First node</a1><a2>Second node</a2><a3>Third <bx />node</a3></root>"
            @doc2 = @doc.dup
            @fragment_string = "<b1>foo</b1><b2>bar</b2>"
            @fragment        = Nokogiri::XML::DocumentFragment.parse @fragment_string
            @node_set        = Nokogiri::XML("<root><b1>foo</b1><b2>bar</b2></root>").xpath("/root/node()")
          end

          describe "##{method}" do
            describe "passed a Node" do
              [:current, :another].each do |which|
                describe "passed a Node in the #{which} document" do
                  before do
                    @other_doc = which == :current ? @doc : @doc2
                    @other_node = @other_doc.at_xpath("/root/a2")
                  end

                  it "unlinks the Node from its previous position" do
                    @doc.at_xpath(params[:target]).send(method, @other_node)
                    @other_doc.at_xpath("/root/a2").must_be_nil
                  end

                  it "inserts the Node in the proper position" do
                    @doc.at_xpath(params[:target]).send(method, @other_node)
                    @doc.at_xpath("/root/a1/a2").wont_be_nil
                  end

                  it "returns the expected value" do
                    if params[:returns] == :self
                      sendee = @doc.at_xpath(params[:target])
                      sendee.send(method, @other_node).must_equal sendee
                    else
                      @doc.at_xpath(params[:target]).send(method, @other_node).must_equal @other_node
                    end
                  end
                end
              end
            end
            describe "passed a markup string" do
              it "inserts the fragment roots in the proper position" do
                @doc.at_xpath(params[:target]).send(method, @fragment_string)
                @doc.xpath("/root/a1/node()").collect {|n| n.name}.must_equal params[:children_tags]
              end
            end
            describe "passed a fragment" do
              it "inserts the fragment roots in the proper position" do
                @doc.at_xpath(params[:target]).send(method, @fragment)
                @doc.xpath("/root/a1/node()").collect {|n| n.name}.must_equal params[:children_tags]
              end
            end
            describe "passed a document" do
              it "raises an exception" do
                proc { @doc.at_xpath("/root/a1").send(method, @doc2) }.must_raise(ArgumentError)
              end
            end
            describe "passed a non-Node" do
              it "raises an exception" do
                proc { @doc.at_xpath("/root/a1").send(method, 42) }.must_raise(ArgumentError)
              end
            end
            describe "passed a NodeSet" do
              it "inserts each member of the NodeSet in the proper order" do
                @doc.at_xpath(params[:target]).send(method, @node_set)
                @doc.xpath("/root/a1/node()").collect {|n| n.name}.must_equal params[:children_tags]
              end
            end
          end
        end

        describe "text node merging" do
          describe "#add_child" do
            it "merges the Text node with adjacent Text nodes" do
              @doc.at_xpath("/root/a1").add_child Nokogiri::XML::Text.new('hello', @doc)
              @doc.at_xpath("/root/a1/text()").content.must_equal "First nodehello"
            end
          end
          describe "#replace" do
            it "merges the Text node with adjacent Text nodes" do
              @doc.at_xpath("/root/a3/bx").replace Nokogiri::XML::Text.new('hello', @doc)
              @doc.at_xpath("/root/a3/text()").content.must_equal "Third hellonode"
            end
          end
        end
      end

      describe "ad hoc node reparenting behavior" do
        before do
          @xml = Nokogiri::XML "<root><a1>First node</a1><a2>Second node</a2><a3>Third node</a3></root>"
          @html = Nokogiri::HTML(<<-eohtml)
            <html>
              <head></head>
              <body>
                <div class='baz'><a href="foo" class="bar">first</a></div>
              </body>
            </html>
          eohtml
        end

        describe "#add_child" do
          describe "given a new node with a namespace" do
            it "keeps the namespace" do
              doc   = Nokogiri::XML::Document.new
              item  = Nokogiri::XML::Element.new('item', doc)
              doc.root = item

              entry = Nokogiri::XML::Element.new('entry', doc)
              entry.add_namespace('tlm', 'http://tenderlovemaking.com')
              assert_equal 'http://tenderlovemaking.com', entry.namespaces['xmlns:tlm']
              item.add_child(entry)
              assert_equal 'http://tenderlovemaking.com', entry.namespaces['xmlns:tlm']
            end
          end

          describe "given a parent node with a default namespace" do
            before do
              @doc = Nokogiri::XML(<<-eoxml)
                <root xmlns="http://tenderlovemaking.com/">
                  <first>
                  </first>
                </root>
              eoxml
            end

            it "inserts a node that inherits the default namespace" do
              assert node = @doc.at('//xmlns:first')
              child = Nokogiri::XML::Node.new('second', @doc)
              node.add_child(child)
              assert @doc.at('//xmlns:second')
            end
          end

          describe "given a parent node with a non-default namespace" do
            before do
              @doc = Nokogiri::XML(<<-eoxml)
                <root xmlns="http://tenderlovemaking.com/" xmlns:foo="http://flavorjon.es/">
                  <first>
                  </first>
                </root>
              eoxml
            end

            describe "and a child node with a namespace matching the parent's non-default namespace" do
              it "inserts a node that inherits the matching parent namespace" do
                assert node = @doc.at('//xmlns:first')
                child = Nokogiri::XML::Node.new('second', @doc)

                ns = @doc.root.namespace_definitions.detect { |x| x.prefix == "foo" }
                child.namespace = ns

                node.add_child(child)
                assert @doc.at('//foo:second', "foo" => "http://flavorjon.es/")
              end
            end
          end
        end

        describe "#replace" do
          describe "when a document has a default namespace" do
            before do
              @fruits = Nokogiri::XML(<<-eoxml)
                <fruit xmlns="http://fruits.org">
                  <apple />
                </fruit>
              eoxml
            end

            it "inserts a node with default namespaces" do
              apple = @fruits.css('apple').first

              orange = Nokogiri::XML::Node.new('orange', @fruits)
              apple.replace(orange)

              assert_equal orange, @fruits.css('orange').first
            end
          end
        end

        describe "unlinking a node and then reparenting it" do
          it "not blow up" do
            # see http://github.com/tenderlove/nokogiri/issues#issue/22
            10.times do
              STDOUT.putc "."
              STDOUT.flush
              begin
                doc = Nokogiri::XML <<-EOHTML
                  <root>
                    <a>
                      <b/>
                      <c/>
                    </a>
                  </root>
                EOHTML

                root = doc.at("root")
                a = root.at("a")
                b = a.at("b")
                c = a.at("c")
                a.add_next_sibling(b.unlink)
                c.unlink
              end
              GC.start
            end
          end
        end

        describe "replace-merging text nodes" do
          [
            ['<root>a<br/></root>',  'afoo'],
            ['<root>a<br/>b</root>', 'afoob'],
            ['<root><br/>b</root>',  'foob']
          ].each do |xml, result|
            it "doesn't blow up on #{xml}" do
              doc = Nokogiri::XML.parse(xml)
              saved_nodes = doc.root.children
              doc.at_xpath("/root/br").replace(Nokogiri::XML::Text.new('foo', doc))
              saved_nodes.each { |child| child.inspect } # try to cause a crash
              assert_equal result, doc.at_xpath("/root/text()").inner_text
            end
          end
        end
      end
    end
  end
end
