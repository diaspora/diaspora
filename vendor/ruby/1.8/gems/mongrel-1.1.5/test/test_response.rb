# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/testhelp'

include Mongrel

class ResponseTest < Test::Unit::TestCase
  
  def test_response_headers
    out = StringIO.new
    resp = HttpResponse.new(out)
    resp.status = 200
    resp.header["Accept"] = "text/plain"
    resp.header["X-Whatever"] = "stuff"
    resp.body.write("test")
    resp.finished

    assert out.length > 0, "output didn't have data"
  end

  def test_response_200
    io = StringIO.new
    resp = HttpResponse.new(io)
    resp.start do |head,out|
      head["Accept"] = "text/plain"
      out.write("tested")
      out.write("hello!")
    end

    resp.finished
    assert io.length > 0, "output didn't have data"
  end

  def test_response_duplicate_header_squash
    io = StringIO.new
    resp = HttpResponse.new(io)
    resp.start do |head,out|
      head["Content-Length"] = 30
      head["Content-Length"] = 0
    end

    resp.finished

    assert_equal io.length, 95, "too much output"
  end


  def test_response_some_duplicates_allowed
    allowed_duplicates = ["Set-Cookie", "Set-Cookie2", "Warning", "WWW-Authenticate"]
    io = StringIO.new
    resp = HttpResponse.new(io)
    resp.start do |head,out|
      allowed_duplicates.each do |dup|
        10.times do |i|
          head[dup] = i
        end
      end
    end

    resp.finished

    assert_equal io.length, 734, "wrong amount of output"
  end

  def test_response_404
    io = StringIO.new

    resp = HttpResponse.new(io)
    resp.start(404) do |head,out|
      head['Accept'] = "text/plain"
      out.write("NOT FOUND")
    end

    resp.finished
    assert io.length > 0, "output didn't have data"
  end

  def test_response_file
    contents = "PLAIN TEXT\r\nCONTENTS\r\n"
    require 'tempfile'
    tmpf = Tempfile.new("test_response_file")
    tmpf.binmode
    tmpf.write(contents)
    tmpf.rewind

    io = StringIO.new
    resp = HttpResponse.new(io)
    resp.start(200) do |head,out|
      head['Content-Type'] = 'text/plain'
      resp.send_header
      resp.send_file(tmpf.path)
    end
    io.rewind
    tmpf.close
    
    assert io.length > 0, "output didn't have data"
    assert io.read[-contents.length..-1] == contents, "output doesn't end with file payload"
  end

  def test_response_with_custom_reason
    reason = "You made a bad request"
    io = StringIO.new
    resp = HttpResponse.new(io)
    resp.start(400, false, reason) { |head,out| }
    resp.finished

    io.rewind
    assert_match(/.* #{reason}$/, io.readline.chomp, "wrong custom reason phrase")
  end

  def test_response_with_default_reason
    code = 400
    io = StringIO.new
    resp = HttpResponse.new(io)
    resp.start(code) { |head,out| }
    resp.finished

    io.rewind
    assert_match(/.* #{HTTP_STATUS_CODES[code]}$/, io.readline.chomp, "wrong default reason phrase")
  end

end

