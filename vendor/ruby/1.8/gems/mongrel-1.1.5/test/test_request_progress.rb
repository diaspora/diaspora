# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/testhelp'

class UploadBeginHandler < Mongrel::HttpHandler
  attr_reader :request_began, :request_progressed, :request_processed

  def initialize
    @request_notify = true
  end

  def reset
    @request_began = false
    @request_progressed = false
    @request_processed = false
  end

  def request_begins(params)
    @request_began = true
  end

  def request_progress(params,len,total)
    @request_progressed = true
  end

  def process(request, response)
    @request_processed = true
    response.start do |head,body|
      body.write("test")
    end
  end

end

class RequestProgressTest < Test::Unit::TestCase
  def setup
    redirect_test_io do
      @server = Mongrel::HttpServer.new("127.0.0.1", 9998)
    end
    @handler = UploadBeginHandler.new
    @server.register("/upload", @handler)
    @server.run
  end

  def teardown
    @server.stop(true)
  end

  def test_begin_end_progress
    Net::HTTP.get("localhost", "/upload", 9998)
    assert @handler.request_began
    assert @handler.request_progressed
    assert @handler.request_processed
  end

  def call_and_assert_handlers_in_turn(handlers)
    # reset all handlers
    handlers.each { |h| h.reset }

    # make the call
    Net::HTTP.get("localhost", "/upload", 9998)

    # assert that each one was fired
    handlers.each { |h|
      assert h.request_began && h.request_progressed && h.request_processed,
        "Callbacks NOT fired for #{h}"
    }
  end

  def test_more_than_one_begin_end_progress
    handlers = [@handler]

    second = UploadBeginHandler.new
    @server.register("/upload", second)
    handlers << second
    call_and_assert_handlers_in_turn(handlers)

    # check three handlers
    third = UploadBeginHandler.new
    @server.register("/upload", third)
    handlers << third
    call_and_assert_handlers_in_turn(handlers)

    # remove handlers to make sure they've all gone away
    @server.unregister("/upload")
    handlers.each { |h| h.reset }
    Net::HTTP.get("localhost", "/upload", 9998)
    handlers.each { |h|
      assert !h.request_began && !h.request_progressed && !h.request_processed
    }

    # re-register upload to the state before this test
    @server.register("/upload", @handler)
  end
end
