# -*- coding: utf-8 -*-
require "helper"

module Nokogiri
  module HTML
    if RUBY_VERSION =~ /^1\.9/
      class TestDocumentEncoding < Nokogiri::TestCase
        def test_encoding
          doc = Nokogiri::HTML File.open(SHIFT_JIS_HTML, 'rb')

          hello = "こんにちは"

          assert_match doc.encoding, doc.to_html
          assert_match hello.encode('Shift_JIS'), doc.to_html
          assert_equal 'Shift_JIS', doc.to_html.encoding.name

          assert_match hello, doc.to_html(:encoding => 'UTF-8')
          assert_match 'UTF-8', doc.to_html(:encoding => 'UTF-8')
          assert_match 'UTF-8', doc.to_html(:encoding => 'UTF-8').encoding.name
        end

        def test_default_to_encoding_from_string
          bad_charset = <<-eohtml
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=charset=UTF-8">
</head>
<body>
  <a href="http://tenderlovemaking.com/">blah!</a>
</body>
</html>
          eohtml
          doc = Nokogiri::HTML(bad_charset)
          assert_equal bad_charset.encoding.name, doc.encoding

          doc = Nokogiri.parse(bad_charset)
          assert_equal bad_charset.encoding.name, doc.encoding
        end

        def test_encoding_non_utf8
          orig = '日本語が上手です'
          bin = Encoding::ASCII_8BIT
          [Encoding::Shift_JIS, Encoding::EUC_JP].each do |enc|
            html = <<-eohtml.encode(enc)
<html>
<meta http-equiv="Content-Type" content="text/html; charset=#{enc.name}">
<title xml:lang="ja">#{orig}</title></html>
            eohtml
            text = Nokogiri::HTML.parse(html).at('title').inner_text
            assert_equal(
              orig.encode(enc).force_encoding(bin),
              text.encode(enc).force_encoding(bin)
            )
          end
        end

        def test_encoding_with_a_bad_name
          bad_charset = <<-eohtml
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=charset=UTF-8">
</head>
<body>
  <a href="http://tenderlovemaking.com/">blah!</a>
</body>
</html>
          eohtml
          doc = Nokogiri::HTML(bad_charset, nil, 'askldjfhalsdfjhlkasdfjh')
          assert_equal ['http://tenderlovemaking.com/'],
            doc.css('a').map { |a| a['href'] }
        end
      end
    end
  end
end
