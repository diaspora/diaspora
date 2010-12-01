# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/testhelp'

include Mongrel

class TestHandler < Mongrel::HttpHandler
  attr_reader :ran_test

  def process(request, response)
    @ran_test = true
    response.socket.write("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nhello!\n")
  end
end


class WebServerTest < Test::Unit::TestCase

  def setup
    @valid_request = "GET / HTTP/1.1\r\nHost: www.zedshaw.com\r\nContent-Type: text/plain\r\n\r\n"
    
    redirect_test_io do
      # We set num_processors=1 so that we can test the reaping code
      @server = HttpServer.new("127.0.0.1", 9998, num_processors=1)
    end
    
    @tester = TestHandler.new
    @server.register("/test", @tester)
    redirect_test_io do
      @server.run 
    end
  end

  def teardown
    redirect_test_io do
      @server.stop(true)
    end
  end

  def test_simple_server
    hit(['http://localhost:9998/test'])
    assert @tester.ran_test, "Handler didn't really run"
  end


  def do_test(string, chunk, close_after=nil, shutdown_delay=0)
    # Do not use instance variables here, because it needs to be thread safe
    socket = TCPSocket.new("127.0.0.1", 9998);
    request = StringIO.new(string)
    chunks_out = 0

    while data = request.read(chunk)
      chunks_out += socket.write(data)
      socket.flush
      sleep 0.2
      if close_after and chunks_out > close_after
        socket.close
        sleep 1
      end
    end
    sleep(shutdown_delay)
    socket.write(" ") # Some platforms only raise the exception on attempted write
    socket.flush
  end

  def test_trickle_attack
    do_test(@valid_request, 3)
  end

  def test_close_client
    assert_raises IOError do
      do_test(@valid_request, 10, 20)
    end
  end

  def test_bad_client
    redirect_test_io do
      do_test("GET /test HTTP/BAD", 3)
    end
  end

  def test_header_is_too_long
    redirect_test_io do
      long = "GET /test HTTP/1.1\r\n" + ("X-Big: stuff\r\n" * 15000) + "\r\n"
      assert_raises Errno::ECONNRESET, Errno::EPIPE, Errno::ECONNABORTED, Errno::EINVAL, IOError do
        do_test(long, long.length/2, 10)
      end
    end
  end

  def test_num_processors_overload
    redirect_test_io do
      assert_raises Errno::ECONNRESET, Errno::EPIPE, Errno::ECONNABORTED, Errno::EINVAL, IOError do
        tests = [
          Thread.new { do_test(@valid_request, 1) },
          Thread.new { do_test(@valid_request, 10) },
        ]

        tests.each {|t| t.join}
      end
    end
  end

  def test_file_streamed_request
    body = "a" * (Mongrel::Const::MAX_BODY * 2)
    long = "GET /test HTTP/1.1\r\nContent-length: #{body.length}\r\n\r\n" + body
    do_test(long, Mongrel::Const::CHUNK_SIZE * 2 -400)
  end

end

