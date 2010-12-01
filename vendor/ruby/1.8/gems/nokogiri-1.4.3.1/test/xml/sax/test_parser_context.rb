# -*- coding: utf-8 -*-

require "helper"

module Nokogiri
  module XML
    module SAX
      class TestParserContext < Nokogiri::SAX::TestCase
        def test_replace_entities
          pc = ParserContext.new StringIO.new('<root />'), 'UTF-8'
          pc.replace_entities = false
          assert_equal false, pc.replace_entities

          pc.replace_entities = true
          assert_equal true, pc.replace_entities
        end

        def test_from_io
          assert_nothing_raised do
            ParserContext.new StringIO.new('fo'), 'UTF-8'
          end
        end

        def test_from_string
          assert_nothing_raised do
            ParserContext.new 'blah blah'
          end
        end

        def test_parse_with
          ctx = ParserContext.new 'blah'
          assert_raises ArgumentError do
            ctx.parse_with nil
          end
        end

        def test_parse_with_sax_parser
          assert_nothing_raised do
            xml = "<root />"
            ctx = ParserContext.new xml
            parser = Parser.new Doc.new
            ctx.parse_with parser
          end
        end

        def test_from_file
          assert_nothing_raised do
            ctx = ParserContext.file XML_FILE
            parser = Parser.new Doc.new
            ctx.parse_with parser
          end
        end

        def test_parse_with_returns_nil
          xml = "<root />"
          ctx = ParserContext.new xml
          parser = Parser.new Doc.new
          assert_nil ctx.parse_with(parser)
        end
      end
    end
  end
end
