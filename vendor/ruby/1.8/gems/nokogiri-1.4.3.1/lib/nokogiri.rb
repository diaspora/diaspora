# -*- coding: utf-8 -*-
# Modify the PATH on windows so that the external DLLs will get loaded.

require 'rbconfig'
ENV['PATH'] = [File.expand_path(
  File.join(File.dirname(__FILE__), "..", "ext", "nokogiri")
), ENV['PATH']].compact.join(';') if RbConfig::CONFIG['host_os'] =~ /(mswin|mingw)/i

if ENV['NOKOGIRI_FFI'] || RUBY_PLATFORM =~ /java/
  require 'ffi'
  require 'nokogiri/ffi/libxml'
else
  require 'nokogiri/nokogiri'
end

warn(<<-eowarn) if '1.8.6' == RUBY_VERSION && $VERBOSE
!!! DEPRECATION WARNING !!!
Hey Champ!  I see you're using Ruby 1.8.6!  While I applaud you for sticking to
your guns and using The One True Ruby, I have to let you know that we're going
to stop supporting 1.8.6.  I know, it's sad.  But, we just don't have time to
support every version of Ruby out there.  Whether we like it or not, time moves
forward and so does our software.

On August 1, 2010, we will no longer support Ruby 1.8.6.  If nokogiri happens to
work on 1.8.6 after that date, then great!  We will hownever, no longer test,
use, or endorse 1.8.6 as a supported platform.

Thanks,

  Team Nokogiri
eowarn

require 'nokogiri/version'
require 'nokogiri/version_warning'
require 'nokogiri/syntax_error'
require 'nokogiri/xml'
require 'nokogiri/xslt'
require 'nokogiri/html'
require 'nokogiri/decorators/slop'
require 'nokogiri/css'
require 'nokogiri/html/builder'

# Nokogiri parses and searches XML/HTML very quickly, and also has
# correctly implemented CSS3 selector support as well as XPath support.
#
# Parsing a document returns either a Nokogiri::XML::Document, or a
# Nokogiri::HTML::Document depending on the kind of document you parse.
#
# Here is an example:
#
#   require 'nokogiri'
#   require 'open-uri'
#
#   # Get a Nokogiri::HTML:Document for the page we’re interested in...
#
#   doc = Nokogiri::HTML(open('http://www.google.com/search?q=tenderlove'))
#
#   # Do funky things with it using Nokogiri::XML::Node methods...
#
#   ####
#   # Search for nodes by css
#   doc.css('h3.r a.l').each do |link|
#     puts link.content
#   end
#
# See Nokogiri::XML::Node#css for more information about CSS searching.
# See Nokogiri::XML::Node#xpath for more information about XPath searching.
module Nokogiri
  class << self
    ###
    # Parse an HTML or XML document.  +string+ contains the document.
    def parse string, url = nil, encoding = nil, options = nil
      doc =
        if string.respond_to?(:read) ||
          string =~ /^\s*<[^Hh>]*html/i # Probably html
          Nokogiri::HTML(
            string,
            url,
            encoding, options || XML::ParseOptions::DEFAULT_HTML
          )
        else
          Nokogiri::XML(string, url, encoding,
                        options || XML::ParseOptions::DEFAULT_XML)
        end
      yield doc if block_given?
      doc
    end

    ###
    # Create a new Nokogiri::XML::DocumentFragment
    def make input = nil, opts = {}, &blk
      if input
        Nokogiri::HTML.fragment(input).children.first
      else
        Nokogiri(&blk)
      end
    end

    ###
    # Parse a document and add the Slop decorator.  The Slop decorator
    # implements method_missing such that methods may be used instead of CSS
    # or XPath.  For example:
    #
    #   doc = Nokogiri::Slop(<<-eohtml)
    #     <html>
    #       <body>
    #         <p>first</p>
    #         <p>second</p>
    #       </body>
    #     </html>
    #   eohtml
    #   assert_equal('second', doc.html.body.p[1].text)
    #
    def Slop(*args, &block)
      Nokogiri(*args, &block).slop!
    end
  end
end

###
# Parser a document contained in +args+.  Nokogiri will try to guess what
# type of document you are attempting to parse.  For more information, see
# Nokogiri.parse
#
# To specify the type of document, use Nokogiri.XML or Nokogiri.HTML.
def Nokogiri(*args, &block)
  if block_given?
    builder = Nokogiri::HTML::Builder.new(&block)
    return builder.doc.root
  else
    Nokogiri.parse(*args)
  end
end
