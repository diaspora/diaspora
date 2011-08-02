#!/usr/bin/env ruby

require 'test/unit'
require 'cgi'
require 'stringio'
require 'timeout'

BOUNDARY = '%?%(\w*)\\((\w*)\\)'
PAYLOAD = "--#{BOUNDARY}\r\nContent-Disposition: form-data; name=\"a_field\"\r\n\r\nBang!\r\n--#{BOUNDARY}--\r\n"
ENV['REQUEST_METHOD'] = "POST"
ENV['CONTENT_TYPE']   = "multipart/form-data; boundary=\"#{BOUNDARY}\""
ENV['CONTENT_LENGTH'] = PAYLOAD.length.to_s

Object.send(:remove_const, :STDERR)
STDERR = StringIO.new # hide the multipart load warnings

version  = RUBY_VERSION.split(".").map {|i| i.to_i }
IS_VULNERABLE = (version [0] < 2 and version [1] < 9 and version [2] < 6 and RUBY_PLATFORM !~ /java/)

class CgiMultipartTestError < StandardError
end

class CgiMultipartEofFixTest < Test::Unit::TestCase

  def read_multipart  
    # can't use STDIN because of the dynamic constant assignment rule
    $stdin = StringIO.new(PAYLOAD) 
  
    begin
      Timeout.timeout(3) do 
        CGI.new
      end
      "CGI is safe: read_multipart does not hang on malicious multipart requests."
    rescue TimeoutError
      raise CgiMultipartTestError, "CGI is exploitable: read_multipart hangs on malicious multipart requests."
    end
  end
  
  def test_exploitable
    if IS_VULNERABLE
      assert_raises CgiMultipartTestError do
        read_multipart
      end
    else
      # we're on 1.8.6 or higher already
      assert_nothing_raised do
        read_multipart      
      end      
    end
  end
  
  def test_fixed
    assert_nothing_raised do
      load "#{File.dirname(__FILE__)}/../lib/cgi_multipart_eof_fix.rb"
      read_multipart
    end
  end  
  
end
