require 'helper'

class MockDecoder; end

describe "MultiXml" do
  context "Parsers" do
    it "should default to the best available gem" do
      pending
      MultiXml.parser.name.should == 'MultiXml::Parsers::Rexml'
      require 'nokogiri'
      MultiXml.parser.name.should == 'MultiXml::Parsers::Nokogiri'
      require 'libxml'
      MultiXml.parser.name.should == 'MultiXml::Parsers::Libxml'
    end

    it "should be settable via a symbol" do
      MultiXml.parser = :libxml
      MultiXml.parser.name.should == 'MultiXml::Parsers::Libxml'
    end

    it "should be settable via a class" do
      MultiXml.parser = MockDecoder
      MultiXml.parser.name.should == 'MockDecoder'
    end
  end

  Dir.glob('lib/multi_xml/parsers/**/*.rb').map{|file| File.basename(file, ".rb").split('_').map{|s| s.capitalize}.join('')}.each do |parser|
    context "Parsers::#{parser}" do
      before do
        begin
          MultiXml.parser = parser
        rescue LoadError
          pending "Parser #{parser} couldn't be loaded"
        end
      end

      describe ".parse" do
        context "a blank string" do
          before do
            @xml = ''
          end

          it "should return an empty Hash" do
            MultiXml.parse(@xml).should == {}
          end
        end

        context "a whitespace string" do
          before do
            @xml = ' '
          end

          it "should return an empty Hash" do
            MultiXml.parse(@xml).should == {}
          end
        end

        context "an invalid XML document" do
          before do
            @xml = '<open></close>'
          end

          it "should raise MultiXml::ParseError" do
            lambda do
              MultiXml.parse(@xml)
            end.should raise_error(MultiXml::ParseError)
          end
        end

        context "a valid XML document" do
          before do
            @xml = '<user/>'
          end

          it "should parse correctly" do
            MultiXml.parse(@xml).should == {'user' => nil}
          end

          context "with CDATA" do
            before do
              @xml = '<user><![CDATA[Erik Michaels-Ober]]></user>'
            end

            it "should return the correct CDATA" do
              MultiXml.parse(@xml)['user'].should == "Erik Michaels-Ober"
            end
          end

          context "with content" do
            before do
              @xml = '<user>Erik Michaels-Ober</user>'
            end

            it "should return the correct content" do
              MultiXml.parse(@xml)['user'].should == "Erik Michaels-Ober"
            end
          end

          context "with an attribute" do
            before do
              @xml = '<user name="Erik Michaels-Ober"/>'
            end

            it "should return the correct attribute" do
              MultiXml.parse(@xml)['user']['name'].should == "Erik Michaels-Ober"
            end
          end

          context "with multiple attributes" do
            before do
              @xml = '<user name="Erik Michaels-Ober" screen_name="sferik"/>'
            end

            it "should return the correct attributes" do
              MultiXml.parse(@xml)['user']['name'].should == "Erik Michaels-Ober"
              MultiXml.parse(@xml)['user']['screen_name'].should == "sferik"
            end
          end

          context "with :symbolize_keys => true" do
            before do
              @xml = '<user><name>Erik Michaels-Ober</name></user>'
            end

            it "should symbolize keys" do
              MultiXml.parse(@xml, :symbolize_keys => true).should == {:user => {:name => "Erik Michaels-Ober"}}
            end
          end

          context "when value is true" do
            before do
              pending
              @xml = '<tag>true</tag>'
            end

            it "should return true" do
              MultiXml.parse(@xml)['tag'].should be_true
            end
          end

          context "when value is false" do
            before do
              pending
              @xml = '<tag>false</tag>'
            end

            it "should return false" do
              MultiXml.parse(@xml)['tag'].should be_false
            end
          end

          context "when key is id" do
            before do
              pending
              @xml = '<id>1</id>'
            end

            it "should return a Fixnum" do
              MultiXml.parse(@xml)['id'].should be_a(Fixnum)
            end

            it "should return the correct number" do
              MultiXml.parse(@xml)['id'].should == 1
            end
          end

          context "when key contains _id" do
            before do
              pending
              @xml = '<tag_id>1</tag_id>'
            end

            it "should return a Fixnum" do
              MultiXml.parse(@xml)['tag_id'].should be_a(Fixnum)
            end

            it "should return the correct number" do
              MultiXml.parse(@xml)['tag_id'].should == 1
            end
          end

          context "with an attribute type=\"boolean\"" do
            %w(true false).each do |boolean|
              context "when #{boolean}" do
                it "should return #{boolean}" do
                  xml = "<tag type=\"boolean\">#{boolean}</tag>"
                  MultiXml.parse(xml)['tag'].should instance_eval("be_#{boolean}")
                end
              end
            end

            context "when 1" do
              before do
                @xml = '<tag type="boolean">1</tag>'
              end

              it "should return true" do
                MultiXml.parse(@xml)['tag'].should be_true
              end
            end

            context "when 0" do
              before do
                @xml = '<tag type="boolean">0</tag>'
              end

              it "should return false" do
                MultiXml.parse(@xml)['tag'].should be_false
              end
            end
          end

          context "with an attribute type=\"integer\"" do
            context "with a positive integer" do
              before do
                @xml = '<tag type="integer">1</tag>'
              end

              it "should return a Fixnum" do
                MultiXml.parse(@xml)['tag'].should be_a(Fixnum)
              end

              it "should return a positive number" do
                MultiXml.parse(@xml)['tag'].should > 0
              end

              it "should return the correct number" do
                MultiXml.parse(@xml)['tag'].should == 1
              end
            end

            context "with a negative integer" do
              before do
                @xml = '<tag type="integer">-1</tag>'
              end

              it "should return a Fixnum" do
                MultiXml.parse(@xml)['tag'].should be_a(Fixnum)
              end

              it "should return a negative number" do
                MultiXml.parse(@xml)['tag'].should < 0
              end

              it "should return the correct number" do
                MultiXml.parse(@xml)['tag'].should == -1
              end
            end
          end

          context "with an attribute type=\"string\"" do
            before do
              @xml = '<tag type="string"></tag>'
            end

            it "should return a String" do
              MultiXml.parse(@xml)['tag'].should be_a(String)
            end

            it "should return the correct string" do
              MultiXml.parse(@xml)['tag'].should == ""
            end
          end

          context "with an attribute type=\"date\"" do
            before do
              @xml = '<tag type="date">1970-01-01</tag>'
            end

            it "should return a Date" do
              MultiXml.parse(@xml)['tag'].should be_a(Date)
            end

            it "should return the correct date" do
              MultiXml.parse(@xml)['tag'].should == Date.parse('1970-01-01')
            end
          end

          context "with an attribute type=\"datetime\"" do
            before do
              @xml = '<tag type="datetime">1970-01-01 00:00</tag>'
            end

            it "should return a Time" do
              MultiXml.parse(@xml)['tag'].should be_a(Time)
            end

            it "should return the correct time" do
              MultiXml.parse(@xml)['tag'].should == Time.parse('1970-01-01 00:00')
            end
          end

          context "with an attribute type=\"dateTime\"" do
            before do
              @xml = '<tag type="datetime">1970-01-01 00:00</tag>'
            end

            it "should return a Time" do
              MultiXml.parse(@xml)['tag'].should be_a(Time)
            end

            it "should return the correct time" do
              MultiXml.parse(@xml)['tag'].should == Time.parse('1970-01-01 00:00')
            end
          end

          context "with an attribute type=\"double\"" do
            before do
              @xml = '<tag type="double">3.14159265358979</tag>'
            end

            it "should return a Float" do
              MultiXml.parse(@xml)['tag'].should be_a(Float)
            end

            it "should return the correct number" do
              MultiXml.parse(@xml)['tag'].should == 3.14159265358979
            end
          end

          context "with an attribute type=\"decimal\"" do
            before do
              @xml = '<tag type="decimal">3.14159265358979323846264338327950288419716939937510</tag>'
            end

            it "should return a BigDecimal" do
              MultiXml.parse(@xml)['tag'].should be_a(BigDecimal)
            end

            it "should return the correct number" do
              MultiXml.parse(@xml)['tag'].should == 3.14159265358979323846264338327950288419716939937510
            end
          end

          context "with an attribute type=\"base64Binary\"" do
            before do
              @xml = '<tag type="base64Binary">aW1hZ2UucG5n</tag>'
            end

            it "should return a String" do
              MultiXml.parse(@xml)['tag'].should be_a(String)
            end

            it "should return the correct string" do
              MultiXml.parse(@xml)['tag'].should == "image.png"
            end
          end

          context "with an attribute type=\"yaml\"" do
            before do
              @xml = "<tag type=\"yaml\">--- \n1: should return an integer\n:message: Have a nice day\narray: \n- should-have-dashes: true\n  should_have_underscores: true\n</tag>"
            end

            it "should return a Hash" do
              MultiXml.parse(@xml)['tag'].should be_a(Hash)
            end

            it "should return the correctly parsed YAML" do
              MultiXml.parse(@xml)['tag'].should == {:message => "Have a nice day", 1 => "should return an integer", "array" => [{"should-have-dashes" => true, "should_have_underscores" => true}]}
            end
          end

          context "with an attribute type=\"file\"" do
            before do
              @xml = '<tag type="file" name="data.txt" content_type="text/plain">ZGF0YQ==</tag>'
            end

            it "should return a StringIO" do
              MultiXml.parse(@xml)['tag'].should be_a(StringIO)
            end

            it "should be decoded correctly" do
              MultiXml.parse(@xml)['tag'].string.should == 'data'
            end

            it "should have the correct file name" do
              MultiXml.parse(@xml)['tag'].original_filename.should == 'data.txt'
            end

            it "should have the correct content type" do
              MultiXml.parse(@xml)['tag'].content_type.should == 'text/plain'
            end

            context "with missing name and content type" do
              before do
                @xml = '<tag type="file">ZGF0YQ==</tag>'
              end

              it "should return a StringIO" do
                MultiXml.parse(@xml)['tag'].should be_a(StringIO)
              end

              it "should be decoded correctly" do
                MultiXml.parse(@xml)['tag'].string.should == 'data'
              end

              it "should have the default file name" do
                MultiXml.parse(@xml)['tag'].original_filename.should == 'untitled'
              end

              it "should have the default content type" do
                MultiXml.parse(@xml)['tag'].content_type.should == 'application/octet-stream'
              end
            end
          end

          context "with an attribute type=\"array\"" do
            before do
              @xml = '<users type="array"><user>Erik Michaels-Ober</user><user>Wynn Netherland</user></users>'
            end

            it "should return an Array" do
              MultiXml.parse(@xml)['users'].should be_a(Array)
            end

            it "should return the correct array" do
              MultiXml.parse(@xml)['users'].should == ["Erik Michaels-Ober", "Wynn Netherland"]
            end
          end

          %w(integer boolean date datetime yaml file).each do |type|
            context "with an empty attribute type=\"#{type}\"" do
              before do
                @xml = "<tag type=\"#{type}\"/>"
              end

              it "should return nil" do
                MultiXml.parse(@xml)['tag'].should be_nil
              end
            end
          end

          context "with an empty attribute type=\"array\"" do
            before do
              @xml = '<tag type="array"/>'
            end

            it "should return an empty Array" do
              MultiXml.parse(@xml)['tag'].should == []
            end

            context "with whitespace" do
              before do
                @xml = '<tag type="array"> </tag>'
              end

              it "should return an empty Array" do
                MultiXml.parse(@xml)['tag'].should == []
              end
            end
          end

          context "with XML entities" do
            before do
              @xml_entities = {
                "<" => "&lt;",
                ">" => "&gt;",
                '"' => "&quot;",
                "'" => "&apos;",
                "&" => "&amp;"
              }
            end

            context "in content" do
              it "should return unescaped XML entities" do
                @xml_entities.each do |key, value|
                  xml = "<tag>#{value}</tag>"
                  MultiXml.parse(xml)['tag'].should == key
                end
              end
            end

            context "in attribute" do
              it "should return unescaped XML entities" do
                @xml_entities.each do |key, value|
                  xml = "<tag attribute=\"#{value}\"/>"
                  MultiXml.parse(xml)['tag']['attribute'].should == key
                end
              end
            end
          end

          context "with dasherized tag" do
            before do
              @xml = '<tag-1/>'
            end

            it "should return undasherize tag" do
              MultiXml.parse(@xml).keys.should include('tag_1')
            end
          end

          context "with dasherized attribute" do
            before do
              @xml = '<tag attribute-1="1"></tag>'
            end

            it "should return undasherize attribute" do
              MultiXml.parse(@xml)['tag'].keys.should include('attribute_1')
            end
          end

          context "with children" do
            context "with attributes" do
              before do
                @xml = '<users><user name="Erik Michaels-Ober"/></users>'
              end

              it "should return the correct attributes" do
                MultiXml.parse(@xml)['users']['user']['name'].should == "Erik Michaels-Ober"
              end
            end

            context "with text" do
              before do
                @xml = '<user><name>Erik Michaels-Ober</name></user>'
              end

              it "should return the correct text" do
                MultiXml.parse(@xml)['user']['name'].should == "Erik Michaels-Ober"
              end
            end

            context "with an unrecognized attribute type" do
              before do
                @xml = '<user type="admin"><name>Erik Michaels-Ober</name></user>'
              end

              it "should pass through the type" do
                MultiXml.parse(@xml)['user']['type'].should == 'admin'
              end
            end

            context "with newlines and whitespace" do
              before do
                @xml = <<-XML
                  <user>
                    <name>Erik Michaels-Ober</name>
                  </user>
                XML
              end

              it "should parse correctly" do
                MultiXml.parse(@xml).should == {"user" => {"name" => "Erik Michaels-Ober"}}
              end
            end

            # Babies having babies
            context "with children" do
              before do
                @xml = '<users><user name="Erik Michaels-Ober"><status text="Hello"/></user></users>'
              end

              it "should parse correctly" do
                MultiXml.parse(@xml).should == {"users" => {"user" => {"name" => "Erik Michaels-Ober", "status" => {"text" => "Hello"}}}}
              end
            end
          end

          context "with sibling children" do
            before do
              @xml = '<users><user>Erik Michaels-Ober</user><user>Wynn Netherland</user></users>'
            end

            it "should return an Array" do
              MultiXml.parse(@xml)['users']['user'].should be_a(Array)
            end

            it "should parse correctly" do
              MultiXml.parse(@xml).should == {"users" => {"user" => ["Erik Michaels-Ober", "Wynn Netherland"]}}
            end
          end
        end
      end
    end
  end
end
